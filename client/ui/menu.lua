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
        value = title or ShopName or _U('wagonShop'),
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

---@param entity integer|nil
---@return boolean
function ShopUI.EntityExists(entity)
    return type(entity) == 'number' and entity ~= 0 and DoesEntityExist(entity)
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
        distance = tonumber(overrides.distance) or tonumber(defaults.distance) or 3.00,
        minimumFov = tonumber(overrides.minimumFov) or tonumber(defaults.minimumFov) or 30.0,
        maximumFov = tonumber(overrides.maximumFov) or tonumber(defaults.maximumFov) or 65.0,
        horizontalOffset = tonumber(overrides.horizontalOffset) or tonumber(defaults.horizontalOffset) or 0.85,
        cameraHeightOffset = tonumber(overrides.cameraHeightOffset) or tonumber(defaults.cameraHeightOffset) or 0.45,
        targetHeightOffset = tonumber(overrides.targetHeightOffset) or tonumber(defaults.targetHeightOffset) or 0.05,
        fitPadding = tonumber(overrides.fitPadding) or tonumber(defaults.fitPadding) or 1.10,
        maximumDistance = tonumber(overrides.maximumDistance) or tonumber(defaults.maximumDistance) or 14.0,
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

local function resolvePreviewCameraTarget(preview, cameraConfig)
    local cameraX, cameraY = resolvePreviewCameraPosition(preview, cameraConfig)
    local directionX = cameraX - preview.coords.x
    local directionY = cameraY - preview.coords.y
    local directionLength = math.sqrt(directionX * directionX + directionY * directionY)
    if directionLength < 0.001 then
        return preview.coords.x, preview.coords.y,
            preview.coords.z + cameraConfig.targetHeightOffset
    end

    directionX = directionX / directionLength
    directionY = directionY / directionLength
    return preview.coords.x + directionY * cameraConfig.horizontalOffset,
        preview.coords.y - directionX * cameraConfig.horizontalOffset,
        preview.coords.z + cameraConfig.targetHeightOffset
end

function ShopUI.PlacePreviewWagon(entity, preview)
    if not entity or entity == 0 or not preview then return end

    local previewRig = type(preview.preview) == 'table' and preview.preview or nil
    local cameraConfig = getPreviewCameraSettings(preview)
    local cameraX, cameraY = resolvePreviewCameraPosition(preview, cameraConfig)
    local coords = preview.coords
    local directionX = cameraX - coords.x
    local directionY = cameraY - coords.y
    local directionLength = math.sqrt(directionX * directionX + directionY * directionY)
    local placementX = coords.x
    local placementY = coords.y

    if directionLength > 0.001 then
        directionX = directionX / directionLength
        directionY = directionY / directionLength

        local minimum, maximum = GetModelDimensions(GetEntityModel(entity))
        local halfX = math.abs(maximum.x - minimum.x) * 0.5
        local halfY = math.abs(maximum.y - minimum.y) * 0.5
        local halfZ = math.abs(maximum.z - minimum.z) * 0.5
        local boundsRadius = math.sqrt(halfX * halfX + halfY * halfY + halfZ * halfZ)
        local fov = resolvePreviewFov(preview, cameraConfig)
        local fitDistance = boundsRadius * cameraConfig.fitPadding / math.tan(math.rad(fov * 0.5))
        local framedDistance = math.min(cameraConfig.maximumDistance, math.max(directionLength, fitDistance))
        local placementOffset = framedDistance - directionLength

        placementX = placementX - directionX * placementOffset
        placementY = placementY - directionY * placementOffset
    end

    SetEntityCoordsNoOffset(entity, placementX, placementY, coords.z - 1.0, false, false, false)
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

    local cameraConfig = getPreviewCameraSettings(preview)
    local cameraX, cameraY, cameraZ = resolvePreviewCameraPosition(preview, cameraConfig)
    local targetX, targetY, targetZ = resolvePreviewCameraTarget(preview, cameraConfig)
    local fov = resolvePreviewFov(preview, cameraConfig)

    SetCamCoord(ShopCam, cameraX, cameraY, cameraZ)
    PointCamAtCoord(
        ShopCam,
        targetX,
        targetY,
        targetZ
    )
    SetCamFov(ShopCam, fov)
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
    local shopEntity = ShopEntity
    if ShopUI.EntityExists(shopEntity) then
        ---@cast shopEntity integer
        SetEntityAsMissionEntity(shopEntity, true, true)
        DeleteEntity(shopEntity)
    end
    ShopEntity = 0

    local ownedEntity = MyEntity
    if ShopUI.EntityExists(ownedEntity) then
        ---@cast ownedEntity integer
        SetEntityAsMissionEntity(ownedEntity, true, true)
        DeleteEntity(ownedEntity)
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


local function OpenShopMenu()
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
            Core.NotifyRightTip(_U('privatePreviewUnavailable'), 5000)
            finish(false)
            return
        end

        finish(ShopUI.CreatePreviewCamera())
    end)
end

function RefreshShopMenu()
    local site = Site
    if ShopMenu then ShopMenu:Close() end
    if site then OpenWagonShop(site) end
end

function OpenWagonShop(site)
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

        Core.NotifyRightTip(_U('rosterLoadFailed'), 5000)
    end)
end

