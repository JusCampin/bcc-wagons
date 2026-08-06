local BUSY_SPINNER_TEXT <const> = 0x7F78CD75CC4539E4
local BUSY_SPINNER_OFF <const> = 0x58F441B90EA84D06

local function configurePreviewWagon(entity, wagon, preview, onReady)
    ShopUI.PlacePreviewWagon(entity, preview or ShopUI.GetPreviewWagonConfig())
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, entity, true) -- FreezeEntityPosition

    ShopUI.CleanPreviewWagon(entity, onReady)
end

local function showPreviewCamera()
    if Cam then return end
    Cam = true
    CameraLighting()
end

local function previewWagon(wagon)
    CreateThread(function()
        local cached = GetCachedWagon(wagon.id)
        if cached and cached.entity ~= 0 and DoesEntityExist(cached.entity) then
            MyEntity = cached.entity
            MyEntityID = wagon.id
            configurePreviewWagon(MyEntity, wagon, ShopUI.GetPreviewWagonConfig())
            ShopUI.FramePreviewCamera(MyEntity)
            showPreviewCamera()
            return
        end

        ClearShopWagon()
        local requestId = ShopUI.BeginPreviewRequest()
        local modelName = wagon.model
        local model = modelName and joaat(modelName)
        if not model then return end

        Citizen.InvokeNative(BUSY_SPINNER_TEXT, CreateVarString(10, 'LITERAL_STRING', _U('loadingWagon')))
        if not LoadModel(model, modelName) or not ShopUI.IsPreviewRequestCurrent(requestId) then
            Citizen.InvokeNative(BUSY_SPINNER_OFF)
            return
        end

        local spawn = ShopUI.GetPreviewWagonConfig()
        if not spawn then
            SetModelAsNoLongerNeeded(model)
            Citizen.InvokeNative(BUSY_SPINNER_OFF)
            return
        end

        local coords = spawn.coords
        local spawnZ = coords.z - 1.0
        local entity = CreateDraftVehicle(model, coords.x, coords.y, spawnZ, spawn.heading, false, false, true, 0 , false)
        SetModelAsNoLongerNeeded(model)

        if not CheckEntityExists(entity) or not ShopUI.IsPreviewRequestCurrent(requestId) then
            if entity and entity ~= 0 and DoesEntityExist(entity) then DeleteEntity(entity) end
            Citizen.InvokeNative(BUSY_SPINNER_OFF)
            return
        end

        MyEntity = entity
        MyEntityID = wagon.id
        ShopUI.HidePreviewWagon(entity)
        configurePreviewWagon(entity, wagon, spawn, function(ready)
            if not ShopUI.IsPreviewRequestCurrent(requestId) then
                if not ShopUI.EntityExists(MyEntity) and not ShopUI.EntityExists(ShopEntity) then
                    Citizen.InvokeNative(BUSY_SPINNER_OFF)
                end
                return
            end
            if ready then ShopUI.RevealPreviewWagon(entity) end
            Citizen.InvokeNative(BUSY_SPINNER_OFF)
        end)
        ShopUI.FramePreviewCamera(entity)
        showPreviewCamera()
        SetCachedWagon(wagon.id, wagon, entity)
    end)
end

local function findRosterWagon(wagonId)
    local targetId = tonumber(wagonId)
    if not targetId or type(MyWagonsData) ~= 'table' then return nil end
    for _, wagon in ipairs(MyWagonsData) do
        if tonumber(wagon.id) == targetId then return wagon end
    end
    return nil
end

function PreviewActiveRosterWagon()
    if type(MyWagonsData) ~= 'table' then return false end
    for _, wagon in ipairs(MyWagonsData) do
        if wagon.is_selected == true then
            previewWagon(wagon)
            return true
        end
    end
    return false
end

---Rebuilds the roster around one wagon so the active marker, expanded actions,
---and physical preview always describe the same entry.
---@param wagonId number|string
---@param persist boolean|nil
---@return boolean
function ShowSelectedWagonRoster(wagonId, persist)
    local wagon = findRosterWagon(wagonId)
    if not wagon then
        ExpandedWagonId = nil
        BuildMyWagonsPage()
        ShopUI.OpenPage('my_wagons')
        return false
    end

    SetSelectedWagonLocally(wagon.id, persist)
    ExpandedWagonId = wagon.id
    InvalidateWagonCache()
    BuildMyWagonsPage()
    ShopUI.OpenPage('my_wagons')
    previewWagon(wagon)
    return true
end

local function addWagonActions(page, wagon)
    local wagonIsOut = MyWagon and MyWagon ~= 0 and DoesEntityExist(MyWagon)
    local selectedWagonIsOut = wagonIsOut and tonumber(MyWagonId) == tonumber(wagon.id)
    local shopActionLabel = selectedWagonIsOut and _U('returnPrompt')
        or (wagonIsOut and _U('switchWagon') or _U('takeOutWagon'))
    local actions = {
        {
            id = 'shop_action', label = shopActionLabel,
            style = selectedWagonIsOut and ShopUI.Styles.danger or ShopUI.Styles.success,
            run = function()
                StopRotation()
                ManageWagonAtShop(wagon.id, Site)
            end,
        },
        {
            id = 'details', label = _U('viewDetails'),
            run = function()
                StopRotation()
                BuildWagonDetailPage(wagon, 'my_wagons')
                ShopUI.OpenPage('wagon_detail')
            end,
        },
        {
            id = 'rename', label = _U('renameWagon'),
            run = function()
                OpenNamingPage({
                    origin = 'updateWagon',
                    wagonId = tonumber(wagon.id),
                    name = wagon.name or '',
                })
            end,
        },
        {
            id = 'sell', label = _U('sellWagon'),
            run = function()
                if BuildWagonSellPage(wagon) then ShopUI.OpenPage('wagon_sell') end
            end,
        },
    }

    for _, action in ipairs(actions) do
        ShopUI.AddButton(
            page,
            ('wagon_%s_%s'):format(wagon.id, action.id),
            '    ' .. action.label,
            'content',
            action.run,
            action.style or ShopUI.Styles.text
        )
    end
end

function BuildMyWagonsPage()
    local page = ShopUI.RegisterPage('my_wagons')
    ShopUI.AddHeader(page, _U('myWagons'))

    if type(MyWagonsData) ~= 'table' or #MyWagonsData == 0 then
        ShopUI.AddText(page, 'wagon_roster_empty', _U('noPersonalWagon'))
    else
        for _, wagon in ipairs(MyWagonsData) do
            local expanded = tonumber(ExpandedWagonId) == tonumber(wagon.id)
            local name = wagon.name or _U('wagonNumber', wagon.id)
            if wagon.is_selected == true then name = _U('activeWagonLabel', name) end

            ShopUI.AddButton(
                page,
                'wagon_select_' .. wagon.id,
                expanded and (name .. ' ▼') or name,
                'content',
                function()
                    StopRotation()
                    local isCurrentlyExpanded = tonumber(ExpandedWagonId) == tonumber(wagon.id)

                    if isCurrentlyExpanded then
                        ExpandedWagonId = nil
                        BuildMyWagonsPage()
                        ShopUI.OpenPage('my_wagons')
                        return
                    end

                    ExpandedWagonId = wagon.id
                    SetSelectedWagonLocally(wagon.id, true)
                    BuildMyWagonsPage()
                    ShopUI.OpenPage('my_wagons')
                    previewWagon(wagon)
                end,
                expanded and ShopUI.Styles.subheader or ShopUI.Styles.button
            )

            if expanded then addWagonActions(page, wagon) end
        end
    end

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'wagon_roster_rotate', '↻ ' .. _U('rotateButton'), 'footer', function()
        ShopUI.ToggleRotation(-1)
    end)
    ShopUI.AddButton(page, 'wagon_roster_shop', _U('shopButton'), 'footer', function()
        StopRotation()
        BuildShopPage()
        ShopUI.OpenPage('shop')
    end)
end
