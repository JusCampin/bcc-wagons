local Core = exports.vorp_core:GetCore()
---@type BCCWagonsDebugLib
local DBG = BCCWagonsDebug
-- Prompts
local ShopPrompt, ReturnPrompt
local ShopGroup = GetRandomIntInRange(0, 0xffffff)
local TradePrompt
local TradeGroup = GetRandomIntInRange(0, 0xffffff)
local LootPrompt
local LootGroup = GetRandomIntInRange(0, 0xffffff)
local WagonMenuPrompt, BrakePrompt
local WagonGroup = GetRandomIntInRange(0, 0xffffff)
local ActionPrompt
local ActionGroup = GetRandomIntInRange(0, 0xffffff)
local PromptsStarted, TradePromptsStarted = false, false
-- Wagons
local MyEntity, ShopName, ShopEntity, SiteCfg, Speed, Format, HasJob
local InMenu, IsShopClosed = false, false
local Cam = false
local IsWainwright = false
MyWagon, MyWagonId, MyWagonName, MyWagonModel = 0, nil, nil, nil
WagonCfg, RepairLevel = {}, 0
IsWagonDamaged, IsBrakeSet, Trading = false, false, false

local function StartPrompts()
    DBG.Info('Starting main prompts...')

    if PromptsStarted then
        DBG.Success('Prompts are already started')
        return true
    end

    if not ShopGroup or not LootGroup then
        DBG.Error('Prompt groups are not initialized')
        return false
    end

    if not Config.keys.shop or not Config.keys.ret or not Config.keys.loot then
        DBG.Error('One or more key bindings for prompts are missing in the configuration')
        return false
    end

    ShopPrompt = UiPromptRegisterBegin()
    DBG.Info('Creating ShopPrompt...')
    if not ShopPrompt or ShopPrompt == 0 then
        DBG.Error('Failed to register ShopPrompt')
        return false
    end
    UiPromptSetControlAction(ShopPrompt, Config.keys.shop)
    UiPromptSetText(ShopPrompt, CreateVarString(10, 'LITERAL_STRING', _U('shopPrompt')))
    UiPromptSetVisible(ShopPrompt, true)
    UiPromptSetStandardMode(ShopPrompt, true)
    UiPromptSetGroup(ShopPrompt, ShopGroup, 0)
    UiPromptRegisterEnd(ShopPrompt)

    ReturnPrompt = UiPromptRegisterBegin()
    DBG.Info('Creating ReturnPrompt...')
    if not ReturnPrompt or ReturnPrompt == 0 then
        DBG.Error('Failed to register ReturnPrompt')
        return false
    end
    UiPromptSetControlAction(ReturnPrompt, Config.keys.ret)
    UiPromptSetText(ReturnPrompt, CreateVarString(10, 'LITERAL_STRING', _U('returnPrompt')))
    UiPromptSetVisible(ReturnPrompt, true)
    UiPromptSetStandardMode(ReturnPrompt, true)
    UiPromptSetGroup(ReturnPrompt, ShopGroup, 0)
    UiPromptRegisterEnd(ReturnPrompt)

    LootPrompt = UiPromptRegisterBegin()
    DBG.Info('Creating LootPrompt...')
    if not LootPrompt or LootPrompt == 0 then
        DBG.Error('Failed to register LootPrompt')
        return false
    end
    UiPromptSetControlAction(LootPrompt, Config.keys.loot)
    UiPromptSetText(LootPrompt, CreateVarString(10, 'LITERAL_STRING', _U('lootWagonPrompt')))
    UiPromptSetVisible(LootPrompt, true)
    UiPromptSetEnabled(LootPrompt, true)
    UiPromptSetStandardMode(LootPrompt, true)
    UiPromptSetGroup(LootPrompt, LootGroup, 0)
    UiPromptRegisterEnd(LootPrompt)

    PromptsStarted = true
    DBG.Success('Main prompts started successfully')
    return true
end

local function isShopClosed(siteCfg)
    local hour = GetClockHours()
    local hoursActive = siteCfg.shop.hours.active

    if not hoursActive then
        return false
    end

    local openHour = siteCfg.shop.hours.open
    local closeHour = siteCfg.shop.hours.close

    if openHour < closeHour then
        -- Normal: shop opens and closes on the same day
        return hour < openHour or hour >= closeHour
    else
        -- Overnight: shop closes on the next day
        return hour < openHour and hour >= closeHour
    end
end

local function ManageSiteBlip(site, closed)
    local siteCfg = Sites[site]

    if (closed and not siteCfg.blip.show.closed) or (not siteCfg.blip.show.open) then
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        return
    end

    if not siteCfg.Blip then
        siteCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, siteCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(siteCfg.Blip, siteCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, siteCfg.Blip, siteCfg.blip.name)               -- SetBlipName
    end

    local color = siteCfg.blip.color.open
    if siteCfg.shop.jobsEnabled then color = siteCfg.blip.color.job end
    if closed then color = siteCfg.blip.color.closed end

    if Config.BlipColors[color] then
        Citizen.InvokeNative(0x662D364ABF16DE2F, siteCfg.Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
    else
        print('Error: Blip color not defined for color: ' .. tostring(color))
    end
end

---@param model number
---@param modelName string
---@return boolean
local function LoadModel(model, modelName)
    -- Validate input
    if not model or not modelName then
        DBG.Error(('Invalid model or modelName for LoadModel: %s, %s'):format(tostring(model), tostring(modelName)))
        return false
    end

    -- Check if model is already loaded
    if HasModelLoaded(model) then
        DBG.Success(('Model already loaded: %s'):format(tostring(modelName)))
        return true
    end

    -- Check if model is valid
    if not IsModelValid(model) then
        DBG.Error(('Invalid model: %s'):format(tostring(modelName)))
        return false
    end

    -- Request model
    DBG.Info(('Requesting model: %s'):format(tostring(modelName)))
    RequestModel(model, false)

    -- Set timeout (5 seconds)
    local timeout = 5000
    local startTime = GetGameTimer()

    -- Wait for model to load
    while not HasModelLoaded(model) do
        -- Check for timeout
        if GetGameTimer() - startTime > timeout then
            DBG.Error(('Timeout while loading model: %s'):format(tostring(modelName)))
            return false
        end
        Wait(10)
    end

    DBG.Success(('Model loaded successfully: %s'):format(tostring(modelName)))
    return true
end

---@param site string
local function AddNPC(site)
    -- Validate site configuration
    if not site then
        DBG.Error(('Invalid site: %s'):format(tostring(site)))
        return false
    end

    local siteCfg = Sites[site]
    if not siteCfg or not siteCfg.npc then
        DBG.Error(('Invalid site configuration for: %s'):format(tostring(site)))
        return false
    end

    -- Check if NPC already exists
    if siteCfg.NPC then
        DBG.Warning(('NPC already exists for site: %s'):format(tostring(site)))
        return true
    end

    -- Validate NPC coordinates and model
    local coords = siteCfg.npc.coords
    if not coords then
        DBG.Error(('Invalid NPC coordinates for site: %s'):format(tostring(site)))
        return false
    end

    local modelName = siteCfg.npc.model
    if not modelName then
        DBG.Error(('Invalid NPC model for site: %s'):format(tostring(site)))
        return false
    end

    -- Load model and create the NPC
    local model = joaat(modelName)
    if not LoadModel(model, modelName) then
        DBG.Error(('Failed to load NPC model for site: %s'):format(tostring(site)))
        return false
    end

    -- Create the NPC
    siteCfg.NPC = CreatePed(model, coords.x, coords.y, coords.z, siteCfg.npc.heading, false, false, false, false)

    if not siteCfg.NPC or not DoesEntityExist(siteCfg.NPC) then
        DBG.Error(('Failed to create NPC for site: %s'):format(tostring(site)))
        return false
    end

    -- Configure the NPC
    Citizen.InvokeNative(0x283978A15512B2FE, siteCfg.NPC, true) -- SetRandomOutfitVariation
    --TaskStartScenarioInPlace(siteCfg.NPC, "WORLD_HUMAN_SMOKING", -1, true)

    SetEntityCanBeDamaged(siteCfg.NPC, false)
    SetEntityInvincible(siteCfg.NPC, true)
    Wait(500)
    FreezeEntityPosition(siteCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(siteCfg.NPC, true)

    DBG.Info(('Successfully added NPC for site: %s, Model: %s'):format(tostring(site), tostring(modelName)))
    return true
end

---@param site string
---@return boolean
local function RemoveNPC(site)
    -- Validate site input
    if not site then
        DBG.Error(('Invalid site: %s'):format(tostring(site)))
        return false
    end

    -- Check if site configuration exists
    local siteCfg = Sites[site]
    if not siteCfg then
        DBG.Error(('Site configuration not found: %s'):format(tostring(site)))
        return false
    end

    -- Check if NPC exists
    if not siteCfg.NPC then
        DBG.Info(('No NPC to remove for site: %s'):format(tostring(site)))
        return true -- Site is valid, but no NPC exists (no-op)
    end

    -- Check if the entity exists before deletion
    if not DoesEntityExist(siteCfg.NPC) then
        DBG.Warning(('NPC entity does not exist for site: %s'):format(tostring(site)))
        siteCfg.NPC = nil -- Clean up reference
        return true -- Site is valid, but entity was already gone
    end

    -- Delete the NPC entity
    DeleteEntity(siteCfg.NPC)
    siteCfg.NPC = nil

    DBG.Info(('Successfully removed NPC for site: %s'):format(tostring(site)))
    return true
end

RegisterNetEvent('vorp:SelectedCharacter', function()
    TriggerEvent('bcc-wagons:StartMainThread')
end)

if Config.devMode.active then
    RegisterCommand(Config.devMode.command, function()
        TriggerEvent('bcc-wagons:StartMainThread')
    end, false)
end

AddEventHandler('bcc-wagons:StartMainThread', function()
    DBG.Info('Starting main thread')

    CreateThread(function()
        StartPrompts()

        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local sleep = 1000

            -- Skip processing if player is in menu or dead
            if InMenu or IsEntityDead(playerPed) then
                Wait(1000)
                goto continue
            end

            for site, siteCfg in pairs(Sites) do
                -- Calculate distance to site
                local distance = #(playerCoords - siteCfg.npc.coords)
                IsShopClosed = isShopClosed(siteCfg)
                ManageSiteBlip(site, IsShopClosed)

                -- Handle NPC spawning/despawning based on distance and shop status
                if distance > siteCfg.npc.distance or IsShopClosed then
                    RemoveNPC(site)
                elseif siteCfg.npc.active then
                    AddNPC(site)
                end

                -- Skip to next site if too far from shop
                if distance > siteCfg.shop.distance then
                    goto next_site
                end

                sleep = 0

                -- Set prompt text based on shop status
                local promptText
                if IsShopClosed then
                    promptText = ('%s %s %d %s %d %s'):format(
                        siteCfg.shop.name,
                        _U('hours'),
                        siteCfg.shop.hours.open,
                        _U('to'),
                        siteCfg.shop.hours.close,
                        _U('hundred')
                    )
                else
                    promptText = siteCfg.shop.prompt
                end

                UiPromptSetActiveGroupThisFrame(ShopGroup, CreateVarString(10, 'LITERAL_STRING', promptText), 1, 0, 0, 0)
                -- Enable/disable prompts based on shop status
                UiPromptSetEnabled(ShopPrompt, not IsShopClosed)
                UiPromptSetEnabled(ReturnPrompt, not IsShopClosed)

                -- Handle prompt interactions
                if not IsShopClosed then
                    -- Shop menu prompt
                    if UiPromptHasStandardModeCompleted(ShopPrompt, 0) then
                        if siteCfg.shop.jobsEnabled then
                            HasJob = CheckPlayerJob(false, site)
                            if not HasJob then
                                goto next_site
                            end
                        end
                        OpenMenu(site)
                    -- Return wagon prompt
                    elseif UiPromptHasStandardModeCompleted(ReturnPrompt, 0) then
                        if siteCfg.shop.jobsEnabled then
                            HasJob = CheckPlayerJob(false, site)
                            if not HasJob then
                                goto next_site
                            end
                        end
                        ReturnWagon()
                    end
                end
                ::next_site::
            end
            ::continue::
            Wait(sleep)
        end
    end)
end)

-- Camera to View Wagons in Shop Menu
---@return boolean
local function CreateCamera()
    -- Validate SiteCfg
    if not SiteCfg or not SiteCfg.wagon or not SiteCfg.wagon.camera or not SiteCfg.wagon.coords then
        DBG.Error('Invalid SiteCfg for camera creation.')
        return false
    end

    -- Create camera
    local wagonCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not wagonCam or not DoesCamExist(wagonCam) then
        DBG.Error('Failed to create camera for wagon menu.')
        return false
    end

    -- Configure camera position and target
    SetCamCoord(wagonCam, SiteCfg.wagon.camera.x, SiteCfg.wagon.camera.y, SiteCfg.wagon.camera.z + 2.0)
    SetCamActive(wagonCam, true)
    PointCamAtCoord(wagonCam, SiteCfg.wagon.coords.x, SiteCfg.wagon.coords.y, SiteCfg.wagon.coords.z)

    -- Screen fade for smooth transition
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)

    -- Render the camera
    RenderScriptCams(true, false, 0, false, false, 0)

     -- Play sound effect
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend

    DBG.Info('Successfully created and configured wagon shop camera.')
    return true
end

---@param site string
function OpenMenu(site)
    -- Validate site input
    if not site then
        DBG.Error('Invalid site provided to OpenMenu.')
        return
    end

    -- Hide radar and freeze player
    DisplayRadar(false)
    TaskStandStill(PlayerPedId(), -1)

    -- Set menu state and site data
    InMenu = true
    SiteCfg = Sites[site]
    ShopName = SiteCfg.shop.name

    -- Create camera and open wagon menu
    if not CreateCamera() then
        DBG.Error('Failed to create camera for wagon menu.')
        InMenu = false
        DisplayRadar(true)
        ClearPedTasksImmediately(PlayerPedId())
        return
    end

    WagonMenu()
end

function WagonMenu()
    -- Clean up any existing shop entity
    if ShopEntity and DoesEntityExist(ShopEntity) then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
        DBG.Info('Deleted existing shop entity.')
    end

    -- Fetch player's wagons and job
    local result = Core.Callback.TriggerAwait('bcc-wagons:GetMyWagons')
    if not result then
        DBG.Error('Failed to fetch wagon data.')
        return
    end

    local wagonData = result[1]
    local job = result[2]

    -- Filter wagons by job
    local jobMatchedWagons = FindWagonsByJob(job)
    if not jobMatchedWagons then
        DBG.Warning('No wagons found for filtering.')
        jobMatchedWagons = {} -- Fallback to empty table
    end

    -- Validate both wagonData and jobMatchedWagons before sending to NUI
    if not wagonData then
        DBG.Warning('No wagon data available to display.')
        return
    end

    if not next(jobMatchedWagons) then -- Check if jobMatchedWagons is empty
        DBG.Warning('No job-matched wagons available to display.')
        return
    end

    -- Send data to NUI if wagon data exists
    SendNUIMessage({
        action = 'show',
        shopData = jobMatchedWagons,
        translations = Translations,
        location = ShopName,
        myWagonsData = wagonData,
        currencyType = Config.currencyType
    })
    SetNuiFocus(true, true)
    DBG.Info('Opened wagon menu with NUI focus.')
end

local function CameraLighting()
    while Cam do
        Wait(0)
        Citizen.InvokeNative(0xD2D9E04C0DF927F4, SiteCfg.wagon.coords.x, SiteCfg.wagon.coords.y, SiteCfg.wagon.coords.z + 3, 130, 130, 85, 4.0, 15.0) -- DrawLightWithRange
    end
end

RegisterNUICallback('LoadWagon', function(data, cb)
    cb('ok')
    if MyEntity then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    local model = data.wagonModel
    local hash = joaat(model)
    LoadModel(hash, model)

    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    ShopEntity = CreateVehicle(hash, SiteCfg.wagon.coords, SiteCfg.wagon.heading, false, false, false, false)
    Citizen.InvokeNative(0x7263332501E07F52, ShopEntity, true) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShopEntity, true) -- FreezeEntityPosition
    SetModelAsNoLongerNeeded(hash)
    if not Cam then
        Cam = true
        CameraLighting()
    end
end)

RegisterNUICallback('BuyWagon', function(data, cb)
    cb('ok')
    CheckPlayerJob(true, false)

    if SiteCfg.wainwrightBuy and not IsWainwright then
        Core.NotifyRightTip(_U('wainwrightBuyWagon'), 4000)
        WagonMenu()
        return
    end

    if IsWainwright then
        data.isWainwright = true
    else
        data.isWainwright = false
    end

    local canBuy = Core.Callback.TriggerAwait('bcc-wagons:BuyWagon', data)
    if canBuy then
        SetWagonName(data, false)
    else
        WagonMenu()
    end
end)

function SetWagonName(data, rename)
    SendNUIMessage({
        action = 'hide'
    })
    SetNuiFocus(false, false)
    Wait(200)

    CreateThread(function()
        AddTextEntry('FMMC_MPM_NA', _U('nameWagon'))
        DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', '', '', '', '', 30)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(0)
        end
        if GetOnscreenKeyboardResult() then
            local wagonName = GetOnscreenKeyboardResult()
            if string.len(wagonName) > 0 then
                if not rename then
                    local wagonSaved = Core.Callback.TriggerAwait('bcc-wagons:SaveNewWagon', data, wagonName)
                    if wagonSaved then
                        WagonMenu()
                    end
                    return
                else
                    local nameSaved = Core.Callback.TriggerAwait('bcc-wagons:UpdateWagonName', data, wagonName)
                    if nameSaved then
                        WagonMenu()
                    end
                    return
                end
            else
                SetWagonName(data, rename)
                return
            end
        end

        WagonMenu()
    end)
end

RegisterNUICallback('RenameWagon', function(data, cb)
    cb('ok')
    SetWagonName(data, true)
end)

RegisterNUICallback('LoadMyWagon', function(data, cb)
    cb('ok')
    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end

    local model = data.wagonModel
    local hash = joaat(model)
    LoadModel(hash, model)

    if MyEntity then
        DeleteEntity(MyEntity)
        MyEntity = nil
    end

    MyEntity = CreateVehicle(hash, SiteCfg.wagon.coords, SiteCfg.wagon.heading, false, false, false, false)
    Citizen.InvokeNative(0x7263332501E07F52, MyEntity, true) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyEntity, true) -- FreezeEntityPosition
    SetModelAsNoLongerNeeded(hash)
    if not Cam then
        Cam = true
        CameraLighting()
    end
end)

RegisterNUICallback('SelectWagon', function(data, cb)
    cb('ok')
    DBG.Info(('Selecting wagon with ID: %s'):format(data.wagonId))
    TriggerServerEvent('bcc-wagons:SelectWagon', data)
end)

function GetSelectedWagon()
    local data = Core.Callback.TriggerAwait('bcc-wagons:GetWagonData')
    if data then
        SpawnWagon(data.model, data.name, false, data.id)
    end
end

local function SetWagonDamaged()
    if MyWagon == 0 then return end
    IsWagonDamaged = true
    Core.NotifyRightTip(_U('needRepairs'), 4000)
    Citizen.InvokeNative(0x260BE8F09E326A20, MyWagon, 10.0, 2000, true) -- BringVehicleToHalt
    IsBrakeSet = true
    PromptSetText(BrakePrompt, CreateVarString(10, 'LITERAL_STRING', _U('brakeOff')))
end

RegisterNUICallback('SpawnData', function(data, cb)
    cb('ok')
    SpawnWagon(data.wagonModel, data.wagonName, true, data.wagonId)
end)

function SpawnWagon(wagonModel, wagonName, menuSpawn, wagonId)
    ResetWagon()

    for _, wagonTypes in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonTypes.models) do
            if model == wagonModel then
                WagonCfg = wagonConfig
                break
            end
        end
    end

    MyWagonModel = wagonModel
    MyWagonName = wagonName
    MyWagonId = wagonId
    local hash = joaat(wagonModel)
    LoadModel(hash, wagonModel)

    if menuSpawn then
        MyWagon = CreateVehicle(hash, SiteCfg.wagon.coords, SiteCfg.wagon.heading, true, false, false, false)
        Citizen.InvokeNative(0x7263332501E07F52, MyWagon, true) -- SetVehicleOnGroundProperly
        SetModelAsNoLongerNeeded(hash)
        if Config.seated then
            DoScreenFadeOut(500)
            Wait(500)
            SetPedIntoVehicle(PlayerPedId(), MyWagon, -1)
            Wait(500)
            DoScreenFadeIn(500)
        end
    else
        local pCoords = GetEntityCoords(PlayerPedId())
        local _, node, heading = GetClosestVehicleNodeWithHeading(pCoords.x, pCoords.y, pCoords.z, 1, 3.0, 0)
        local index = 0
        while index <= 25 do
            local nodeCheck, _node, _heading = GetNthClosestVehicleNodeWithHeading(pCoords.x, pCoords.y, pCoords.z, index, 9, 3.0, 2.5)
            if nodeCheck  then
                node = _node
                heading = _heading
                break
            else
                index = index + 3
            end
        end
        MyWagon = CreateVehicle(hash, node, heading, true, false, false, false)
        Citizen.InvokeNative(0x7263332501E07F52, MyWagon, true) -- SetVehicleOnGroundProperly
        SetModelAsNoLongerNeeded(hash)
    end

    Citizen.InvokeNative(0xD0E02AA618020D17, PlayerId(), MyWagon) -- SetPlayerOwnsVehicle
    Citizen.InvokeNative(0xE2487779957FE897, MyWagon, 528) -- SetTransportUsageFlags

    if WagonCfg.inventory.enabled then
        TriggerServerEvent('bcc-wagons:RegisterInventory', MyWagonId, wagonModel)
        if WagonCfg.inventory.shared then
            Entity(MyWagon).state:set('myWagonId', MyWagonId, true)
        end
    end

    if WagonCfg.gamerTag.enabled then
        TriggerEvent('bcc-wagons:WagonTag')
    end

    if WagonCfg.blip.enabled then
        TriggerEvent('bcc-wagons:WagonBlip')
    end

    if WagonCfg.brakeSet then
        Citizen.InvokeNative(0x260BE8F09E326A20, MyWagon, 0.0, 2000, true) -- BringVehicleToHalt
        IsBrakeSet = true
    end

    if WagonCfg.condition.enabled then
        RepairLevel = GetCondition()
        if RepairLevel < WagonCfg.condition.decreaseValue then
            SetWagonDamaged()
        end
        TriggerEvent('bcc-wagons:RepairMonitor')
    end

    TriggerEvent('bcc-wagons:SpeedMonitor')

    TriggerEvent('bcc-wagons:WagonPrompts')
end

-- Loot Players Wagon Inventory
CreateThread(function()
    while true do
        local vehicle, wagonId, owner = nil, nil, nil
        local isWagon = false
        local playerPed = PlayerPedId()
        local coords = (GetEntityCoords(playerPed))
        local sleep = 1000

        if (IsEntityDead(playerPed)) or (not IsPedOnFoot(playerPed)) then goto END end

        vehicle = Citizen.InvokeNative(0x52F45D033645181B, coords.x, coords.y, coords.z, 3.0, 0, 70, Citizen.ResultAsInteger()) -- GetClosestVehicle
        if (vehicle == 0) or (vehicle == MyWagon) then goto END end

        isWagon = Citizen.InvokeNative(0xEA44E97849E9F3DD, vehicle) -- IsDraftVehicle
        if not isWagon then goto END end

        owner = Citizen.InvokeNative(0x7C803BDC8343228D, vehicle) -- GetPlayerOwnerOfVehicle
        if owner == 255 then goto END end

        sleep = 0
        PromptSetActiveGroupThisFrame(LootGroup, CreateVarString(10, 'LITERAL_STRING', _U('lootInventory')), 1, 0, 0, 0)
        if Citizen.InvokeNative(0xC92AC953F0A982AE, LootPrompt) then  -- PromptHasStandardModeCompleted
            wagonId = Entity(vehicle).state.myWagonId
            TriggerServerEvent('bcc-wagons:OpenInventory', wagonId)
        end
        ::END::
        Wait(sleep)
    end
end)

AddEventHandler('bcc-wagons:RepairMonitor', function()
    local decreaseTime = (WagonCfg.condition.decreaseTime * 1000)
    local decreaseValue = WagonCfg.condition.decreaseValue
    if not IsWagonDamaged then
        Wait(decreaseTime) -- Wait after spawning wagon
    end
    while MyWagon ~= 0 do
        if RepairLevel >= decreaseValue then
            IsWagonDamaged = false
            local newLevel = Core.Callback.TriggerAwait('bcc-wagons:UpdateRepairLevel', MyWagonId, MyWagonModel)
            if newLevel then
                RepairLevel = newLevel
            end
        end
        if IsWagonDamaged then goto END end
        if RepairLevel < decreaseValue then
            SetWagonDamaged()
        end
        ::END::
        Wait(decreaseTime) -- Interval to decrease condition
    end
end)

function GetCondition()
    local condition = Core.Callback.TriggerAwait('bcc-wagons:GetRepairLevel', MyWagonId, MyWagonModel)
    if condition then
        return condition
    elseif condition == nil then
        return 0
    end
end

AddEventHandler('bcc-wagons:SpeedMonitor', function()
    local multiplier
    if Config.speed == 1 then
        multiplier = 2.23694 -- Meters per Second to Miles per Hour
        Format = '~s~mph'
    elseif Config.speed == 2 then
        multiplier = 3.6 -- Meters per Second to Kilometers per Hour
        Format = '~s~kph'
    end

    while MyWagon ~= 0 do
        Wait(1000)
        local entitySpeed = Citizen.InvokeNative(0xFB6BA510A533DF81, MyWagon, Citizen.ResultAsFloat()) -- GetEntitySpeed / Meters per Second
        Speed = math.floor(entitySpeed * multiplier)
    end
end)

AddEventHandler('bcc-wagons:WagonPrompts', function()
    StartWagonPrompts()
    local promptDist = WagonCfg.distance

    while MyWagon ~= 0 do
        local playerPed = PlayerPedId()
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(MyWagon))
        local sleep = 1000

        if distance > promptDist then goto END end

        if IsPedInVehicle(playerPed, MyWagon, false) then
            sleep = 0

            local wagonStats = 'speed: ~o~' .. tostring(Speed) .. Format .. ' | condition: ~o~' .. tostring(RepairLevel)
            PromptSetActiveGroupThisFrame(WagonGroup, CreateVarString(10, 'LITERAL_STRING', wagonStats), 1, 0, 0, 0)

            if Citizen.InvokeNative(0xC92AC953F0A982AE, WagonMenuPrompt) then  -- PromptHasStandardModeCompleted
                OpenWagonMenu()
            end

            if Citizen.InvokeNative(0xC92AC953F0A982AE, BrakePrompt) then  -- PromptHasStandardModeCompleted
                if IsWagonDamaged then goto END end

                if not IsBrakeSet then
                    Citizen.InvokeNative(0x260BE8F09E326A20, MyWagon, 10.0, 2000, true) -- BringVehicleToHalt
                    IsBrakeSet = true
                    PromptSetText(BrakePrompt, CreateVarString(10, 'LITERAL_STRING', _U('brakeOff')))
                else
                    Citizen.InvokeNative(0x7C06330BFDDA182E, MyWagon) -- StopBringingVehicleToHalt
                    IsBrakeSet = false
                    PromptSetText(BrakePrompt, CreateVarString(10, 'LITERAL_STRING', _U('brakeOn')))
                end
            end

        else
            sleep = 0

            PromptSetActiveGroupThisFrame(ActionGroup, CreateVarString(10, 'LITERAL_STRING', MyWagonName), 1, 0, 0, 0)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, ActionPrompt) then  -- PromptHasStandardModeCompleted
                OpenWagonMenu()
            end
        end
        ::END::
        Wait(sleep)
    end
end)

-- Set Wagon Name Above Wagon
AddEventHandler('bcc-wagons:WagonTag', function()
    local playerPed = PlayerPedId()
    local tagDist = WagonCfg.gamerTag.distance
    local gamerTagId = Citizen.InvokeNative(0xE961BF23EAB76B12, MyWagon, MyWagonName) -- CreateMpGamerTagOnEntity
    while MyWagon ~= 0 do
        Wait(1000)
        local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyWagon))
        if dist <= tagDist and not Citizen.InvokeNative(0xEC5F66E459AF3BB2, playerPed, MyWagon) then -- IsPedOnSpecificVehicle
            Citizen.InvokeNative(0x93171DDDAB274EB8, gamerTagId, 3) -- SetMpGamerTagVisibility
        else
            if Citizen.InvokeNative(0x502E1591A504F843, gamerTagId, MyWagon) then -- IsMpGamerTagActiveOnEntity
                Citizen.InvokeNative(0x93171DDDAB274EB8, gamerTagId, 0) -- SetMpGamerTagVisibility
            end
        end
    end
    Citizen.InvokeNative(0x839BFD7D7E49FE09, Citizen.PointerValueIntInitialized(gamerTagId)) -- RemoveMpGamerTag
end)

-- Set Blip on Spawned Wagon when Empty
AddEventHandler('bcc-wagons:WagonBlip', function()
    local playerPed = PlayerPedId()
    local wagonBlip
    while MyWagon ~= 0 do
        Wait(1000)
        if Citizen.InvokeNative(0xEC5F66E459AF3BB2, playerPed, MyWagon) then -- IsPedOnSpecificVehicle
            if wagonBlip then
                RemoveBlip(wagonBlip)
                wagonBlip = nil
            end
        else
            if not wagonBlip then
                wagonBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, MyWagon) -- BlipAddForEntity
                SetBlipSprite(wagonBlip, joaat(WagonCfg.blip.sprite), true)
                Citizen.InvokeNative(0x9CB1A1623062F402, wagonBlip, MyWagonName) -- SetBlipName
            end
        end
    end
end)

RegisterNUICallback('SellWagon', function(data, cb)
    cb('ok')
    DeleteEntity(MyEntity)
    Cam = false
    local wagonSold = Core.Callback.TriggerAwait('bcc-wagons:SellMyWagon', data)
    if wagonSold then
        WagonMenu()
    end
end)

-- Close Wagon Shop Menu
RegisterNUICallback('CloseWagon', function(data, cb)
    cb('ok')

    -- Hide the NUI and release focus
    SendNUIMessage({ action = 'hide' })
    SetNuiFocus(false, false)

    -- Play sound effect
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Hide', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend

    -- Clean up shop entity
    if ShopEntity and DoesEntityExist(ShopEntity) then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
        DBG.Info('Deleted shop entity.')
    end

    -- Clean up player's wagon entity
    if MyEntity and DoesEntityExist(MyEntity) then
        DeleteEntity(MyEntity)
        MyEntity = nil
        DBG.Info('Deleted player wagon entity.')
    end

    -- Clean up camera
    if Cam then
        Cam = false
        DestroyAllCams(true)
        DBG.Info('Destroyed all script cameras.')
    end

    -- Restore game state
    DisplayRadar(true)
    ClearPedTasksImmediately(PlayerPedId())
    InMenu = false

    DBG.Info('Successfully closed wagon shop menu.')
end)

-- Call Selected Wagon
CreateThread(function()
    if Config.callEnabled then
        local callKey = Config.keys.call
        while true do
            Wait(0)
            if Citizen.InvokeNative(0x580417101DDB492F, 2, callKey) then -- IsControlJustPressed
                if MyWagon ~= 0 then
                    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(MyWagon))
                    if dist >= Config.callDist then
                        GetSelectedWagon()
                    else
                        Core.NotifyRightTip(_U('tooClose'), 5000)
                    end
                else
                    GetSelectedWagon()
                end
            end
        end
    end
end)

-- Return Wagon Using Prompt at Shop Location
function ReturnWagon()
    if MyWagon ~= 0 then
        ResetWagon()
        Core.NotifyRightTip(_U('wagonReturned'), 4000)
    else
        Core.NotifyRightTip(_U('noWagonReturn'), 4000)
    end
end

AddEventHandler('bcc-wagons:TradeWagon', function()
    while Trading do
        local playerPed = PlayerPedId()
        local sleep = 1000

        if IsEntityDead(playerPed) or IsPedOnSpecificVehicle(playerPed, MyWagon) then
            Trading = false
            PromptDelete(TradePrompt)
            break
        end

        local closestPlayer, closestDistance = GetClosestPlayer()
        if closestPlayer and closestDistance <= 2.0 then
            sleep = 0
            PromptSetActiveGroupThisFrame(TradeGroup, CreateVarString(10, 'LITERAL_STRING', MyWagonName))
            if Citizen.InvokeNative(0xE0F65F0640EF0617, TradePrompt) then  -- PromptHasHoldModeCompleted
                local serverId = GetPlayerServerId(closestPlayer)
                local tradeComplete = Core.Callback.TriggerAwait('bcc-wagons:SaveWagonTrade', serverId, MyWagonId)
                if tradeComplete then
                    ResetWagon()
                end
                Trading = false
                PromptDelete(TradePrompt)
            end
        end
        Wait(sleep)
    end
end)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local player = PlayerId()
    local coords = GetEntityCoords(PlayerPedId())
    local closestDistance = nil
    local closestPlayer = nil
    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])
        if players[i] ~= player then
            local distance = #(coords - GetEntityCoords(target))
            if closestDistance == nil or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

local function GetControlOfWagon()
    while not NetworkHasControlOfEntity(MyWagon) do
        NetworkRequestControlOfEntity(MyWagon)
        Wait(10)
    end
end

function ResetWagon()
    if MyWagon ~= 0 then
        GetControlOfWagon()
        DeleteEntity(MyWagon)
        MyWagon = 0
    end
    PromptDelete(WagonMenuPrompt)
    PromptDelete(ActionPrompt)
    PromptDelete(BrakePrompt)
    PromptDelete(TradePrompt)
    TradePromptsStarted = false
    Trading = false
end

-- Rotate Wagons while Viewing
RegisterNUICallback('Rotate', function(data, cb)
    cb('ok')
    local direction = data.RotateWagon
    if direction == 'left' then
        Rotation(1)
    elseif direction == 'right' then
        Rotation(-1)
    end
end)

function Rotation(dir)
    if MyEntity then
        local ownedRot = GetEntityHeading(MyEntity) + dir
        SetEntityHeading(MyEntity, ownedRot % 360)
    elseif ShopEntity then
        local shopRot = GetEntityHeading(ShopEntity) + dir
        SetEntityHeading(ShopEntity, shopRot % 360)
    end
end

function CheckPlayerJob(wainwright, site)
    local result = Core.Callback.TriggerAwait('bcc-wagons:CheckJob', wainwright, site)
    if not result then return end

    IsWainwright, HasJob = false, false

    if wainwright and result[1] then
        IsWainwright = true
    elseif site then
        if result[1] then
            HasJob = true
        elseif Sites[site].shop.jobsEnabled then
            Core.NotifyRightTip(_U('needJob'), 4000)
        end
    end
end

RegisterCommand(Config.commands.wagonEnter, function()
    if MyWagon ~= 0 then
        DoScreenFadeOut(500)
        Wait(500)
        SetPedIntoVehicle(PlayerPedId(), MyWagon, -1)
        Wait(500)
        DoScreenFadeIn(500)
    else
        Core.NotifyRightTip(_U('noWagon'), 4000)
    end
end, false)

RegisterCommand(Config.commands.wagonReturn, function()
    if Config.returnEnabled then
        ReturnWagon()
    else
        Core.NotifyRightTip(_U('noReturn'), 4000)
    end
end, false)

function StartWagonPrompts()
    WagonMenuPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(WagonMenuPrompt, Config.keys.menu)
    UiPromptSetText(WagonMenuPrompt, CreateVarString(10, 'LITERAL_STRING', _U('wagonMenuPrompt')))
    UiPromptSetEnabled(WagonMenuPrompt, true)
    UiPromptSetVisible(WagonMenuPrompt, true)
    UiPromptSetStandardMode(WagonMenuPrompt, true)
    UiPromptSetGroup(WagonMenuPrompt, WagonGroup, 0)
    UiPromptRegisterEnd(WagonMenuPrompt)

    BrakePrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(BrakePrompt, Config.keys.brake)
    if WagonCfg.brakeSet then
        UiPromptSetText(BrakePrompt, CreateVarString(10, 'LITERAL_STRING', _U('brakeOff')))
    else
        UiPromptSetText(BrakePrompt, CreateVarString(10, 'LITERAL_STRING', _U('brakeOn')))
    end
    UiPromptSetEnabled(BrakePrompt, true)
    UiPromptSetVisible(BrakePrompt, true)
    UiPromptSetStandardMode(BrakePrompt, true)
    UiPromptSetGroup(BrakePrompt, WagonGroup, 0)
    UiPromptRegisterEnd(BrakePrompt)

    ActionPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(ActionPrompt, Config.keys.action)
    UiPromptSetText(ActionPrompt, CreateVarString(10, 'LITERAL_STRING', _U('wagonMenuPrompt')))
    UiPromptSetEnabled(ActionPrompt, true)
    UiPromptSetVisible(ActionPrompt, true)
    UiPromptSetStandardMode(ActionPrompt, true)
    UiPromptSetGroup(ActionPrompt, ActionGroup, 0)
    UiPromptRegisterEnd(ActionPrompt)
end

function StartTradePrompts()
    if not TradePromptsStarted then
        TradePrompt = UiPromptRegisterBegin()
        UiPromptSetControlAction(TradePrompt, Config.keys.trade)
        UiPromptSetText(TradePrompt, CreateVarString(10, 'LITERAL_STRING', _U('tradePrompt')))
        UiPromptSetEnabled(TradePrompt, true)
        UiPromptSetVisible(TradePrompt, true)
        UiPromptSetHoldMode(TradePrompt, 2000)
        UiPromptSetGroup(TradePrompt, TradeGroup, 0)
        UiPromptRegisterEnd(TradePrompt)

        TradePromptsStarted = true
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if InMenu then
        SendNUIMessage({
            action = 'hide'
        })
        SetNuiFocus(false, false)
    end
    ClearPedTasksImmediately(PlayerPedId())
    DestroyAllCams(true)
    DisplayRadar(true)

    if ShopEntity then
        DeleteEntity(ShopEntity)
        ShopEntity = nil
    end
    if MyWagon ~= 0 then
        DeleteEntity(MyWagon)
        MyWagon = 0
    end

    for _, siteCfg in pairs(Sites) do
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        if siteCfg.NPC then
            DeleteEntity(siteCfg.NPC)
            siteCfg.NPC = nil
        end
    end
end)

-- to count length of maps
local function len(t)
    local counter = 0
    for _, _ in pairs(t) do
        counter += 1
    end
    return counter
end

--let's go fancy with an implementation that orders pairs for you using default table.sort(). Taken from a lua-users post.
local function __genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex)
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.
    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, #(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function FindWagonsByJob(job)
    local matchingWagons = {}
    for _, wagonType in ipairs(Wagons) do
        local matchingModels = {}
        for wagonModel, wagonCfg in orderedPairs(wagonType.models) do
            -- using maps to break a loop, though technically making another loop, albeit simpler. Preferably you already configure jobs as a map so that you could expand
            -- perhaps when a request comes to have model accesses by job grade or similar
            local wagonJobs = {}
            for _, wagonJob in pairs(wagonCfg.job) do
                wagonJobs[wagonJob] = wagonJob
            end
            -- add matching model directly 
            if wagonJobs[job] ~= nil then
                matchingModels[wagonModel] = {
                    label = wagonCfg.label,
                    cashPrice = wagonCfg.price.cash,
                    goldPrice = wagonCfg.price.gold,
                    invLimit = wagonCfg.inventory.limit,
                    job = wagonCfg.job
                }
            end
            --handle case where there isn\t a job attached to wagon model config
            if len(wagonJobs) == 0 then
                matchingModels[wagonModel] = {
                    label = wagonCfg.label,
                    cashPrice = wagonCfg.price.cash,
                    goldPrice = wagonCfg.price.gold,
                    invLimit = wagonCfg.inventory.limit,
                    job = nil
                }
            end
        end

        if len(matchingModels) > 0 then
            matchingWagons[#matchingWagons + 1] = {
                type = wagonType.type,
                models = matchingModels
            }
        end
    end
    return matchingWagons
end