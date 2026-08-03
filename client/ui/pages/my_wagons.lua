local BUSY_SPINNER_TEXT <const> = 0x7F78CD75CC4539E4
local BUSY_SPINNER_OFF <const> = 0x58F441B90EA84D06

local function configurePreviewWagon(entity, wagon, preview, onReady)
    ShopUI.PlacePreviewWagon(entity, preview or ShopUI.GetPreviewWagonConfig())
    Citizen.InvokeNative(0x7263332501E07F52, entity, true) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, entity, true) -- FreezeEntityPosition

    WagonAppearance.resetTracking(entity)
    --WagonAppearance.applyLoadout(entity, wagon.tackLoadout or {})
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

        Citizen.InvokeNative(BUSY_SPINNER_TEXT, CreateVarString(10, 'LITERAL_STRING', 'Loading wagon...'))
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
        local entity = CreateVehicle(model, coords.x, coords.y, spawnZ, spawn.heading, false, false, false, false)
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
                if not DoesEntityExist(MyEntity) and not DoesEntityExist(ShopEntity) then
                    Citizen.InvokeNative(BUSY_SPINNER_OFF)
                end
                return
            end
            if ready then ShopUI.RevealPreviewHorse(entity) end
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
---@param horseId number|string
---@param persist boolean|nil
---@return boolean
function ShowSelectedHorseRoster(horseId, persist)
    local horse = findRosterHorse(horseId)
    if not horse then
        ExpandedHorseId = nil
        BuildMyHorsesPage()
        ShopUI.OpenPage('my_horses')
        return false
    end

    SetSelectedHorseLocally(horse.id, persist)
    ExpandedHorseId = horse.id
    InvalidateHorseCache()
    BuildMyHorsesPage()
    ShopUI.OpenPage('my_horses')
    previewHorse(horse)
    return true
end

local function addHorseActions(page, horse)
    local horseIsOut = MyHorse and MyHorse ~= 0 and DoesEntityExist(MyHorse)
    local selectedHorseIsOut = horseIsOut and tonumber(MyHorseId) == tonumber(horse.id)
    local stableActionLabel = selectedHorseIsOut and (_U('returnPrompt') or 'Return Horse')
        or (horseIsOut and (_U('switchHorse') or 'Switch to This Horse')
            or (_U('takeOutHorse') or 'Take Out Horse'))
    local actions = {
        {
            id = 'stable_action', label = stableActionLabel,
            style = selectedHorseIsOut and ShopUI.Styles.danger or ShopUI.Styles.success,
            run = function()
                StopRotation()
                ManageHorseAtStable(horse.id, Site)
            end,
        },
        {
            id = 'details', label = 'View Stats & Details',
            run = function()
                StopRotation()
                BuildHorseDetailPage(horse, 'my_horses')
                ShopUI.OpenPage('horse_detail')
            end,
        },
        {
            id = 'tack', label = 'Open Tack Shop',
            run = function()
                StopRotation()
                BuildTackShopPage()
            end,
        },
        {
            id = 'rename', label = 'Rename Horse',
            run = function()
                OpenNamingPage({
                    origin = 'updateHorse',
                    horseId = tonumber(horse.id),
                    name = horse.name or '',
                })
            end,
        },
        {
            id = 'sell', label = 'Sell Horse',
            run = function()
                if BuildHorseSellPage(horse) then ShopUI.OpenPage('horse_sell') end
            end,
        },
    }

    for _, action in ipairs(actions) do
        ShopUI.AddButton(
            page,
            ('horse_%s_%s'):format(horse.id, action.id),
            '    ' .. action.label,
            'content',
            action.run,
            action.style or ShopUI.Styles.text
        )
    end
end

function BuildMyHorsesPage()
    local page = ShopUI.RegisterPage('my_horses')
    ShopUI.AddHeader(page, _U('myHorses') or 'My Horses')

    if type(MyHorsesData) ~= 'table' or #MyHorsesData == 0 then
        ShopUI.AddText(page, 'horse_roster_empty', _U('noPersonalHorse') or 'No horses. Visit the trader to purchase one.')
    else
        for _, horse in ipairs(MyHorsesData) do
            local expanded = tonumber(ExpandedHorseId) == tonumber(horse.id)
            local name = horse.name or ('Horse #' .. tostring(horse.id))
            if horse.is_selected == true then name = name .. ' (Active)' end

            ShopUI.AddButton(
                page,
                'horse_select_' .. horse.id,
                expanded and (name .. ' ▼') or name,
                'content',
                function()
                    StopRotation()
                    local isCurrentlyExpanded = tonumber(ExpandedHorseId) == tonumber(horse.id)

                    if isCurrentlyExpanded then
                        ExpandedHorseId = nil
                        BuildMyHorsesPage()
                        ShopUI.OpenPage('my_horses')
                        return
                    end

                    ExpandedHorseId = horse.id
                    SetSelectedHorseLocally(horse.id, true)
                    BuildMyHorsesPage()
                    ShopUI.OpenPage('my_horses')
                    previewHorse(horse)
                end,
                expanded and ShopUI.Styles.subheader or ShopUI.Styles.button
            )

            if expanded then addHorseActions(page, horse) end
        end
    end

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'horse_roster_rotate', '↻ ' .. (_U('rotateButton') or 'Rotate'), 'footer', function()
        ShopUI.ToggleRotation(-1)
    end)
    ShopUI.AddButton(page, 'horse_roster_trader', _U('traderButton') or 'Trader', 'footer', function()
        StopRotation()
        BuildTraderPage()
        ShopUI.OpenPage('trader')
    end)
end
