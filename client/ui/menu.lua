local activeRotateThreadId = 0
local wagonDataCache = {}
local previewRequestId = 0

ShopUI = ShopUI or {}

ShopUI.Styles = {
    header = { ['color'] = '#999' },
    subheader = { ['font-size'] = '1.778vmin', ['color'] = '#CC9900' },
    text = {
        ['color'] = '#C0C0C0',
        ['font-size'] = '1.481vmin',
        ['font-variant'] = 'small-caps',
        ['line-height'] = '1.8',
        ['white-space'] = 'pre-line',
    },
    button = { ['color'] = '#E0E0E0' },
    success = { ['color'] = '#66CC66' },
    danger = { ['color'] = '#CC3333' },
}

function ShopUI.AddHeader(page, subtitle, title)
    page:RegisterElement('header', {
        value = title or ShopName or 'Wagon Shop',
        slot = 'header',
        style = ShopUI.Styles.header,
    })
    page:RegisterElement('subheader', {
        value = subtitle,
        slot = 'header',
        style = ShopUI.Styles.subheader,
    })
    page:RegisterElement('line', { slot = 'header' })
end

function ShopUI.AddText(page, id, value, style)
    return page:RegisterElement('textdisplay', {
        id = id,
        value = value,
        slot = 'content',
        style = style or ShopUI.Styles.text,
    })
end

function ShopUI.AddButton(page, id, label, slot, callback, style)
    return page:RegisterElement('button', {
        id = id,
        label = label,
        slot = slot or 'content',
        style = style or ShopUI.Styles.button,
    }, callback)
end

function ShopUI.AddFooter(page)
    page:RegisterElement('bottomline', { slot = 'footer' })
end

function ShopUI.RegisterPage(key)
    local page = ShopMenu:RegisterPage(key)
    ShopPages[key] = page
    return page
end

function ShopUI.OpenPage(key)
    local page = ShopPages[key]
    if not page then
        DBG:Error(('Cannot open unregistered shop page: %s'):format(tostring(key)))
        return false
    end
    ShopMenu:Open({ startupPage = page })
    return true
end

function ShopUI.Trim(value)
    return type(value) == 'string' and (value:match('^%s*(.-)%s*$') or '') or ''
end

function ShopUI.AsTable(value)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return {} end
    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == 'table' and decoded or {}
end

function ShopUI.GetModel(model)
    local mapping = Wagons.ModelToTypeMap[model]
    local wagonType = mapping and mapping.wagonType
    local catalog = wagonType and Wagons.TypeCatalog[wagonType]
    return wagonType, catalog and catalog.models and catalog.models[model]
end

function ShopUI.GetPreviewWagonConfig()
    local site = Site and Sites[Site]
    return site and site.wagon or nil
end

local function getPreviewCameraSettings(preview)
    local defaults = Config.preview.camera or {}
    local previewRig = type(preview.preview) == 'table' and preview.preview or {}
    local overrides = type(previewRig.cameraSettings) == 'table' and previewRig.cameraSettings or {}

    return {
        fov = tonumber(overrides.fov) or tonumber(defaults.fov),
        referenceFov = tonumber(overrides.referenceFov) or tonumber(defaults.referenceFov) or 42.0,
        referenceDistance = tonumber(overrides.referenceDistance) or tonumber(defaults.referenceDistance) or 4.75,
        distance = tonumber(overrides.distance) or tonumber(defaults.distance) or 3.25,
        minimumFov = tonumber(overrides.minimumFov) or tonumber(defaults.minimumFov) or 30.0,
        maximumFov = tonumber(overrides.maximumFov) or tonumber(defaults.maximumFov) or 65.0,
        horizontalOffset = tonumber(overrides.horizontalOffset) or tonumber(defaults.horizontalOffset) or 0.85,
        cameraHeightOffset = tonumber(overrides.cameraHeightOffset) or tonumber(defaults.cameraHeightOffset) or 0.20,
        targetHeightOffset = tonumber(overrides.targetHeightOffset) or tonumber(defaults.targetHeightOffset) or 0.05,
    }
end

local function resolvePreviewCameraPosition(preview, cameraConfig)
    local previewRig = type(preview.preview) == 'table' and preview.preview or {}
    local heading = math.rad(tonumber(previewRig.heading) or preview.heading or 0.0)
    local side = tonumber(previewRig.cameraSide) == -1 and -1 or 1
    local distance = math.max(0.1, cameraConfig.distance)
    return preview.coords.x + math.cos(heading) * distance * side,
        preview.coords.y + math.sin(heading) * distance * side,
        preview.coords.z + cameraConfig.cameraHeightOffset
end

local function resolvePreviewFov(preview, cameraConfig)
    if cameraConfig.fov then return cameraConfig.fov end

    local cameraX, cameraY = resolvePreviewCameraPosition(preview, cameraConfig)
    local deltaX = cameraX - preview.coords.x
    local deltaY = cameraY - preview.coords.y
    local distance = math.max(0.1, math.sqrt(deltaX * deltaX + deltaY * deltaY))
    local referenceFov = math.rad(cameraConfig.referenceFov * 0.5)
    local fov = math.deg(2.0 * math.atan(cameraConfig.referenceDistance / distance * math.tan(referenceFov)))
    return math.min(cameraConfig.maximumFov, math.max(cameraConfig.minimumFov, fov))
end

function ShopUI.PlacePreviewWagon(entity, preview)
    if not entity or entity == 0 or not preview then return end

    local previewRig = type(preview.preview) == 'table' and preview.preview or nil
    SetEntityHeading(entity, tonumber(previewRig and previewRig.heading) or preview.heading)
    Citizen.InvokeNative(0x9587913B9E772D29, entity, false) -- PlaceEntityOnGroundProperly
end

local function clearPreviewWagonCondition(entity)
    CleanWagonAppearance(entity)
end

function ShopUI.HidePreviewWagon(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end
    SetEntityAlpha(entity, 0, false)
    SetEntityVisible(entity, false, false)
end

function ShopUI.RevealPreviewWagon(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    SetEntityVisible(entity, true, false)
    CreateThread(function()
        for alpha = 40, 240, 40 do
            if not DoesEntityExist(entity) or GetEntityModel(entity) ~= model then return end
            SetEntityAlpha(entity, alpha, false)
            Wait(30)
        end
        if DoesEntityExist(entity) and GetEntityModel(entity) == model then ResetEntityAlpha(entity) end
    end)
end

function ShopUI.CleanPreviewWagon(entity, callback)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        if callback then callback(false) end
        return
    end

    local model = GetEntityModel(entity)
    clearPreviewWagonCondition(entity)

    -- Ped variation is applied asynchronously and can restore condition overlays.
    CreateThread(function()
        Wait(300)
        if DoesEntityExist(entity) and GetEntityModel(entity) == model then
            clearPreviewWagonCondition(entity)
            if callback then callback(true) end
        elseif callback then
            callback(false)
        end
    end)
end

function ShopUI.CreatePreviewCamera()
    local preview = ShopUI.GetPreviewWagonConfig()
    if not preview then return false end
    local cameraConfig = getPreviewCameraSettings(preview)
    local cameraX, cameraY, cameraZ = resolvePreviewCameraPosition(preview, cameraConfig)

    if ShopCam and DoesCamExist(ShopCam) then DestroyCam(ShopCam, true) end
    ShopCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(
        ShopCam,
        cameraX,
        cameraY,
        cameraZ
    )
    PointCamAtCoord(
        ShopCam,
        preview.coords.x,
        preview.coords.y,
        preview.coords.z + cameraConfig.targetHeightOffset
    )
    SetCamFov(ShopCam, resolvePreviewFov(preview, cameraConfig))
    SetCamActive(ShopCam, true)

    DoScreenFadeOut(500)
    Wait(500)
    RenderScriptCams(true, false, 0, false, false, 0)
    DoScreenFadeIn(500)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0)
    return true
end

function ShopUI.FramePreviewCamera(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity)
        or not ShopCam or not DoesCamExist(ShopCam) then return end

    local preview = ShopUI.GetPreviewWagonConfig()
    if not preview then return end

    local entityCoords = GetEntityCoords(entity)
    local cameraConfig = getPreviewCameraSettings(preview)
    local cameraX, cameraY, cameraZ = resolvePreviewCameraPosition(preview, cameraConfig)
    local directionX = cameraX - preview.coords.x
    local directionY = cameraY - preview.coords.y
    local directionLength = math.sqrt(directionX * directionX + directionY * directionY)
    if directionLength < 0.001 then return end

    directionX = directionX / directionLength
    directionY = directionY / directionLength
    local referenceDistance = math.max(0.1, cameraConfig.referenceDistance)
    local horizontalOffset = cameraConfig.horizontalOffset
        * math.min(1.0, directionLength / referenceDistance)
    local targetX = entityCoords.x + directionY * horizontalOffset
    local targetY = entityCoords.y - directionX * horizontalOffset
    local targetZ = preview.coords.z + cameraConfig.targetHeightOffset

    SetCamCoord(
        ShopCam,
        cameraX,
        cameraY,
        cameraZ
    )
    PointCamAtCoord(ShopCam, targetX, targetY, targetZ)
    SetCamFov(ShopCam, resolvePreviewFov(preview, cameraConfig))
end

function ShopUI.ToggleRotation(direction)
    if IsRotating and RotateDirection == direction then
        StopRotation()
    else
        StartRotation(direction)
    end
end

function ShopUI.BeginPreviewRequest()
    previewRequestId = previewRequestId + 1
    return previewRequestId
end

function ShopUI.IsPreviewRequestCurrent(requestId)
    return requestId == previewRequestId
end

function InvalidateWagonCache()
    for _, cache in pairs(wagonDataCache) do
        if cache.entity and cache.entity ~= 0 and DoesEntityExist(cache.entity) then
            SetEntityAsMissionEntity(cache.entity, true, true)
            DeleteEntity(cache.entity)
        end
    end
    wagonDataCache = {}
end

function GetCachedWagon(wagonId)
    return wagonDataCache[wagonId]
end

function SetCachedWagon(wagonId, data, entity)
    wagonDataCache[wagonId] = {
        data = data,
        entity = entity or 0,
    }
end

function UpdateCachedWagonName(wagonId, newName)
    if wagonDataCache[wagonId] then
        wagonDataCache[wagonId].data.name = newName
    end
end

function RemoveCachedWagon(wagonId)
    if wagonDataCache[wagonId] then
        local entity = wagonDataCache[wagonId].entity
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
        wagonDataCache[wagonId] = nil
    end
end

function StartRotation(direction)
    IsRotating = true
    RotateDirection = direction

    activeRotateThreadId = activeRotateThreadId + 1
    local currentThreadInstance = activeRotateThreadId

    CreateThread(function()
        while IsRotating and activeRotateThreadId == currentThreadInstance do
            local entity = (MyEntity and MyEntity ~= 0) and MyEntity or ShopEntity
            if entity and entity ~= 0 and DoesEntityExist(entity) then
                local heading = GetEntityHeading(entity)
                local newHeading = heading + (RotateDirection * 1.0)
                SetEntityHeading(entity, newHeading)
            else
                break
            end
            Wait(15)
        end
    end)
end

function StopRotation()
    IsRotating = false
    RotateDirection = nil
end

ShopMenu = FeatherMenu:RegisterMenu('bcc-wagons:ShopMenu', {
    top = '3%',
    left = '3%',
    ['720width'] = '400px',
    ['1080width'] = '500px',
    ['2kwidth'] = '600px',
    ['4kwidth'] = '800px',
    style = {},
    contentslot = {
        style = {
            ['height'] = '450px',
            ['min-height'] = '325px'
        }
    },
    draggable = true,
    canclose = true
}, {
    opened = function()
        InMenu = true
        DisplayRadar(false)
    end,
    closed = function()
        InMenu = false
        DisplayRadar(true)
        CloseShop()
    end
})

function ClearShopWagon()
    ShopUI.BeginPreviewRequest()
    if ShopEntity ~= 0 and DoesEntityExist(ShopEntity) then
        SetEntityAsMissionEntity(ShopEntity, true, true)
        DeleteEntity(ShopEntity)
    end
    ShopEntity = 0

    if MyEntity ~= 0 and DoesEntityExist(MyEntity) then
        SetEntityAsMissionEntity(MyEntity, true, true)
        DeleteEntity(MyEntity)
    end
    MyEntity = 0
end

function CloseShop()
    StopRotation()
    ClearShopWagon()

    ExpandedWagonId = nil

    DoScreenFadeOut(500)
    Wait(200)
    DoScreenFadeIn(200)

    RenderScriptCams(false, false, 0, false, false, 0)

    if ShopCam and DoesCamExist(ShopCam) then
        DestroyCam(ShopCam, true)
        ShopCam = nil
    end

    Cam = false
    ClearPedTasksImmediately(PlayerPedId())
    ExitPreviewInstance()
end


local function OpenStableMenu()
    ClearShopWagon()

    ExpandedWagonId = nil
    SelectedModelKey = nil
    StopRotation()
    InvalidateWagonCache()

    BuildMyWagonsPage()

    if not ShopMenu then
        DBG:Error('ShopMenu framework object failed to initialize')
        return
    end

    ShopMenu:Open({
        startupPage = ShopPages.my_wagons,
        menuFocus = true,
        cursorFocus = true,
        overrideMenu = true,
        allowKeys = true,
    })
    PreviewActiveRosterWagon()
end

function ShopUI.EnterPreview(callback)
    local function finish(success)
        if callback then callback(success == true) end
    end

    EnterPreviewInstance(function(success)
        if not success then
            Core.NotifyRightTip('The private shop preview is temporarily unavailable.', 5000)
            finish(false)
            return
        end

        finish(ShopUI.CreatePreviewCamera())
    end)
end

function RefreshStableMenu()
    local site = Site
    if ShopMenu then ShopMenu:Close() end
    if site then OpenShop(site) end
end

function OpenShop(site)
    Site = site
    ShopName = Sites[Site].shop.name
    MyWagonsData = nil

    FetchRosterAndAction(function()
        ShopUI.EnterPreview(function(success)
            if success then OpenShopMenu() end
        end)
    end, function()
        DBG:Error('No wagon data received for site: ' .. tostring(site))

        if ShopCam and DoesCamExist(ShopCam) then
            DestroyCam(ShopCam, true)
            ShopCam = nil
        end
        Cam = false

        Core.NotifyRightTip("Failed to retrieve shop records from the cloud. Please retry.", 5000)
    end)
end

