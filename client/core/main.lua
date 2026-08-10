IsWagonFleeingState = false
local shopSnapshot = { site = nil, distance = math.huge, isClosed = false }
local shopPromptStates = { shop = {}, call = {}, returnWagon = {} }

local SHOP_SCAN_INTERVAL_MS <const> = 500
local WAGON_STATE_INTERVAL_MS <const> = 1000
local BLIP_UPDATE_INTERVAL_MS <const> = 5000
local IDLE_PROMPT_INTERVAL_MS <const> = 1000

local GET_EVENT_AT_INDEX_NATIVE <const> = 0xA85E614430EFF816
local GET_EVENT_DATA_NATIVE <const> = 0x57EC5FA4D4D6AFCA
local EVENT_ENTITY_DESTROYED <const> = 2145012826

---@param entity integer|nil
---@return boolean
local function entityExists(entity)
    return type(entity) == 'number' and entity ~= 0 and DoesEntityExist(entity)
end

---@param entity integer|nil
local function deleteEntity(entity)
    if not entityExists(entity) then return end
    ---@cast entity integer

    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
end

local function isAutoReturnExcluded(modelName, distanceCfg)
    if type(modelName) ~= 'string' or type(distanceCfg) ~= 'table' then return false end
    local excludedModels = distanceCfg.excludedModels
    return type(excludedModels) == 'table' and excludedModels[modelName:lower()] == true
end

local function resolveTrackedWagonEntity()
    local wagonData = LocalPlayer.state.WagonData
    local netId = wagonData and tonumber(wagonData.MyWagon)
    if not netId or netId == 0 or not NetworkDoesNetworkIdExist(netId) then return 0 end

    local entity = NetworkGetEntityFromNetworkId(netId)
    return entityExists(entity) and entity or 0
end

CreateThread(function()
    local distanceCfg <const> = Config and Config.shop.autoReturn
    local hasDistanceCheck <const> = distanceCfg and distanceCfg.enabled
    local distanceRadius <const> = distanceCfg and tonumber(distanceCfg.maximumDistance) or 100.0
    local distanceRadiusSquared <const> = distanceRadius * distanceRadius
    local lastActiveWagon = 0

    while true do
        local wagon = MyWagon
        local isWagonActive = false
        local preserveWhenDistant = isAutoReturnExcluded(MyWagonModel, distanceCfg)

        -- Persistent wagons can lose their local handle outside the streaming
        -- bubble. Keep the wagon id/net id and resolve the entity again when
        -- the same network object streams back to this client.
        if preserveWhenDistant and not entityExists(wagon) and not IsSpawningWagonActive then
            local resolvedWagon = resolveTrackedWagonEntity()
            if entityExists(resolvedWagon) then
                MyWagon = resolvedWagon
                wagon = resolvedWagon
                MyWagonModel = MyWagonModel or ResolveWagonModelName(GetEntityModel(resolvedWagon))
                DBG:Info('Persistent wagon streamed back in. Restored local entity tracking.')
                EmitWagonLifecycleEvent('bcc-wagons:client:wagonStreamedIn')
            end
        end

        if entityExists(wagon) and not IsSpawningWagonActive then
            local isAlive = Citizen.InvokeNative(0xB86D29B10F627379, wagon, false, false) -- IsVehicleDriveable
            and not Citizen.InvokeNative(0xDDBEA5506C848227, wagon) -- IsVehicleWrecked

            if hasDistanceCheck and not preserveWhenDistant then
                local playerPed = PlayerPedId()
                local offset = GetEntityCoords(playerPed) - GetEntityCoords(wagon)
                local distanceSquared = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z

                if distanceSquared > distanceRadiusSquared then
                    DBG:Info('Active wagon out of range.Clearing entity.')
                    deleteEntity(wagon)

                    if MyWagon == wagon then
                        MyWagon = 0
                        MyWagonId = nil
                    end

                    isAlive = false
                end
            end

            if isAlive then
                isWagonActive = true
            end
        elseif not preserveWhenDistant
            and not IsSpawningWagonActive
            and not IsPreviewInstanceTransitioning()
            and MyWagon == wagon then
            MyWagon = 0
            MyWagonId = nil
        elseif preserveWhenDistant and not IsSpawningWagonActive and MyWagon == wagon then
            -- The local entity handle is transient; ownership identifiers are
            -- retained so cargo access survives network ownership migration.
            MyWagon = 0
        end

        IsMyWagonActive = isWagonActive

        if isWagonActive and wagon ~= lastActiveWagon then
            DBG:Info('Driveable wagon detected. Initializing tracking loops.')

            -- if (tonumber(Config.care.saveIntervalMinutes) or 0) > 0 then
            --     TriggerEvent('bcc-wagons:WagonMonitor')
            -- end

            if Config.wagonTag.enabled then
                TriggerEvent('bcc-wagons:WagonTag')
            end
        end

        lastActiveWagon = isWagonActive and wagon or 0

        Wait(WAGON_STATE_INTERVAL_MS)
    end
end)

local function isShopClosed(shopCfg, hour)
    hour = hour or GetClockHours()
    local hoursActive = shopCfg.shop.hours.active

    if not hoursActive then
        return false
    end

    local openHour = shopCfg.shop.hours.open
    local closeHour = shopCfg.shop.hours.close

    if openHour < closeHour then
        return hour < openHour or hour >= closeHour
    else
        return hour < openHour and hour >= closeHour
    end
end

---@param prompt integer
---@param stateKey 'shop'|'call'|'returnWagon'
---@param visible boolean|nil
---@param enabled boolean
local function setShopPromptState(prompt, stateKey, visible, enabled)
    local state = shopPromptStates[stateKey]

    if visible ~= nil and state.visible ~= visible then
        UiPromptSetVisible(prompt, visible)
        state.visible = visible
    end

    if state.enabled ~= enabled then
        UiPromptSetEnabled(prompt, enabled)
        state.enabled = enabled
    end
end

local function manageShopBlip(site, closed)
    local siteCfg = Sites[site]

    if (closed and not siteCfg.blip.showClosed) or (not siteCfg.blip.show) then
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        siteCfg.lastBlipColor = nil
        return
    end

    if not siteCfg.Blip then
        siteCfg.Blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, siteCfg.npc.coords.x, siteCfg.npc.coords.y, siteCfg.npc.coords.z) -- BlipAddForCoords
        SetBlipSprite(siteCfg.Blip, siteCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, siteCfg.Blip, siteCfg.blip.name) -- SetBlipName
        siteCfg.lastBlipColor = nil
    end

    local color = siteCfg.blip.color.open
    if siteCfg.shop.jobsEnabled then color = siteCfg.blip.color.job end
    if closed then color = siteCfg.blip.color.closed end

    if siteCfg.lastBlipColor == color then return end

    local colorModifier = Config.map.blipColors[color]
    if colorModifier then
        Citizen.InvokeNative(0x662D364ABF16DE2F, siteCfg.Blip, joaat(colorModifier)) -- BlipAddModifier
    else
        DBG:Warning('Blip color not defined for color: ' .. tostring(color))
    end

    siteCfg.lastBlipColor = color
end

local function addShopNpc(site)
    local siteCfg = Sites[site]
    if siteCfg.NPC then return end

    local modelName = siteCfg.npc.model
    local model = joaat(modelName)

    if not LoadModel(model, modelName) then return end

    siteCfg.NPC = CreatePed(model, siteCfg.npc.coords.x, siteCfg.npc.coords.y, siteCfg.npc.coords.z - 1.0, siteCfg.npc.heading, false, true, true, true)
    if not entityExists(siteCfg.NPC) then
        siteCfg.NPC = nil
        SetModelAsNoLongerNeeded(model)
        DBG:Warning(('Failed to create shop NPC for site: %s'):format(tostring(site)))
        return
    end

    Citizen.InvokeNative(0x283978A15512B2FE, siteCfg.NPC, true) -- SetRandomOutfitVariation

    --TaskStartScenarioInPlace(siteCfg.NPC, `WORLD_HUMAN_WRITE_NOTEBOOK`, -1, true)
    SetEntityCanBeDamaged(siteCfg.NPC, false)
    SetEntityInvincible(siteCfg.NPC, true)
    FreezeEntityPosition(siteCfg.NPC, true)
    SetBlockingOfNonTemporaryEvents(siteCfg.NPC, true)
    SetModelAsNoLongerNeeded(model)
end

local function removeShopNpc(site)
    local siteCfg = Sites[site]
    if siteCfg.NPC then
        deleteEntity(siteCfg.NPC)
        siteCfg.NPC = nil
    end
end

local function clearShopSnapshot()
    shopSnapshot.site = nil
    shopSnapshot.distance = math.huge
    shopSnapshot.isClosed = false
end

local function refreshShopSnapshot()
    local playerPed = PlayerPedId()
    if InMenu or IsEntityDead(playerPed) then
        clearShopSnapshot()
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local hour = GetClockHours()
    local nearestSite = nil
    local nearestDistance = math.huge
    local nearestClosed = false

    for site, siteCfg in pairs(Sites) do
        local distance = #(playerCoords - siteCfg.npc.coords)
        local isClosed = isShopClosed(siteCfg, hour)

        if distance > siteCfg.npc.distance or isClosed then
            removeShopNpc(site)
        elseif siteCfg.npc.active then
            addShopNpc(site)
        end

        if distance < nearestDistance then
            nearestSite = site
            nearestDistance = distance
            nearestClosed = isClosed
        end
    end

    shopSnapshot.site = nearestSite
    shopSnapshot.distance = nearestDistance
    shopSnapshot.isClosed = nearestClosed
end

---@param siteCfg table
---@param isClosed boolean
---@param isWagonSpawned boolean
---@param closedCall boolean
---@param closedReturn boolean
local function updateShopPrompts(siteCfg, isClosed, isWagonSpawned, closedCall, closedReturn)
    local promptHeader

    if isClosed then
        promptHeader = string.format(
            '%s%s%s%s%s%s',
            siteCfg.shop.name,
            _U('hours'),
            siteCfg.shop.hours.open,
            _U('to'),
            siteCfg.shop.hours.close,
            _U('hundred')
        )
    else
        promptHeader = siteCfg.shop.prompt or _U('wagonShop')
    end

    UiPromptSetActiveGroupThisFrame(ShopGroup, CreateVarString(10, 'LITERAL_STRING', promptHeader), 1, 0, 0, 0)
    setShopPromptState(ShopPrompt, 'shop', nil, not isClosed)

    local canCall = not isWagonSpawned and (not isClosed or closedCall)
    setShopPromptState(CallPrompt, 'call', canCall, canCall)

    local canReturn = isWagonSpawned and (not isClosed or closedReturn)
    setShopPromptState(ReturnPrompt, 'returnWagon', canReturn, canReturn)
end

local function runShopAction(site, action)
    local siteCfg = Sites[site]
    if not siteCfg.shop.jobsEnabled or CheckPlayerJob(site) then
        action(site)
    end
end

local function handleShopPromptAction(site, isClosed, isWagonSpawned, closedCall, closedReturn)
    if not isClosed and UiPromptHasStandardModeCompleted(ShopPrompt, 0) then
        runShopAction(site, OpenWagonShop)
        return
    end

    if not isWagonSpawned and UiPromptHasStandardModeCompleted(CallPrompt, 0) then
        if not isClosed or closedCall then
            runShopAction(site, CallActiveWagonAtShop)
        end
        return
    end

    if isWagonSpawned and UiPromptHasStandardModeCompleted(ReturnPrompt, 0) then
        if not isClosed or closedReturn then
            runShopAction(site, ReturnWagon)
        end
    end
end

CreateThread(function()
    while true do
        local hour = GetClockHours()

        for site, siteCfg in pairs(Sites) do
            manageShopBlip(site, isShopClosed(siteCfg, hour))
        end
        Wait(BLIP_UPDATE_INTERVAL_MS)
    end
end)

CreateThread(function()
    while true do
        refreshShopSnapshot()
        Wait(SHOP_SCAN_INTERVAL_MS)
    end
end)

CreateThread(function()
    StartPrompts()
    local closedCall <const> = Config.shop.whileClosed.callWagon == true
    local closedReturn <const> = Config.shop.whileClosed.returnWagon == true

    while true do
        local playerPed = PlayerPedId()
        local sleep = IDLE_PROMPT_INTERVAL_MS

        local site = shopSnapshot.site
        if not InMenu and not IsEntityDead(playerPed) and site then
            local siteCfg = Sites[site]
            local isClosed = shopSnapshot.isClosed

            if shopSnapshot.distance <= siteCfg.shop.distance then
                sleep = 0
                local isWagonSpawned = entityExists(MyWagon)

                updateShopPrompts(siteCfg, isClosed, isWagonSpawned, closedCall, closedReturn)
                handleShopPromptAction(site, isClosed, isWagonSpawned, closedCall, closedReturn)
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    local callSettings = Config.shop.callActiveWagon or {}
    if callSettings.enabled ~= true then return end

    local callControl = Config.controls.callWagon
    while true do
        if not InMenu
            and not IsEntityDead(PlayerPedId())
            and IsControlJustReleased(0, callControl) then
            CallActiveWagon()
        end
        Wait(0)
    end
end)

local function getEventData(eventGroup, eventIndex, dataSize)
    local buffer = CreateEventDataBuffer(dataSize * 8)
    local hasData = Citizen.InvokeNative(
        GET_EVENT_DATA_NATIVE,
        eventGroup,
        eventIndex,
        buffer:Buffer(),
        dataSize
    )

    return hasData and buffer or nil
end

local function handleEntityDestroyedEvent(eventIndex)
    local eventData = getEventData(0, eventIndex, 9)
    if eventData and eventData:GetInt32(0) == MyWagon then
        MyWagon = 0
        MyWagonId = nil
        WagonName = nil
        IsMyWagonActive = false
        LocalPlayer.state.WagonData = { MyWagon = 0 }
    end
end

local gameEventHandlers <const> = {
    [EVENT_ENTITY_DESTROYED] = handleEntityDestroyedEvent
}

local characterSelectionGeneration = 0

-- Long-running resource loops start only once. Character selection resets only
-- character-specific wagon state, preventing duplicate client threads.
RegisterNetEvent('vorp:SelectedCharacter', function()
    characterSelectionGeneration = characterSelectionGeneration + 1
    local generation = characterSelectionGeneration

    if ShopMenu and InMenu then
        ShopMenu:Close()
    else
        ClearShopWagon()
        ExitPreviewInstance()
    end

    local wagon = MyWagon
    if entityExists(wagon) then
        ReturnWagon(true)
    else
        MyWagon = 0
        MyWagonId = nil
        WagonName = nil
        IsMyWagonActive = false
        LocalPlayer.state.WagonData = { MyWagon = 0 }
    end

    MyWagonsData = {}
    MyWagonType = nil
    MyWagonModel = nil
    ExpandedWagonId = nil
    SelectedModelKey = nil
    Site = nil
    ShopName = _U('wagonShop')

    -- Give VORP time to publish the newly selected character state.
    Wait(250)
    Core.Callback.TriggerAsync('bcc-wagons:GetMyWagonsData', function(wagons)
        if generation ~= characterSelectionGeneration then return end
        if type(wagons) ~= 'table' then
            MyWagonsData = {}
            DBG:Warning('Character wagon roster could not be initialized.')
            return
        end

        MyWagonsData = wagons
        local selectedWagonId
        for _, ownedWagon in ipairs(wagons) do
            if ownedWagon.is_selected == true then
                selectedWagonId = ownedWagon.id
                break
            end
        end

        DBG:Info(('Character wagon state initialized. Selected wagon ID: %s'):format(
            tostring(selectedWagonId or 'none')
        ))
    end)
end)

-- A resource restart does not emit SelectedCharacter again for players already
-- online, so initialize from the existing VORP character state as well.
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Wait(500)
        if characterSelectionGeneration == 0 and LocalPlayer.state.Character then
            TriggerEvent('vorp:SelectedCharacter')
        end
    end)
end)

-- Listen for relevant game events every frame.
CreateThread(function()
    while true do
        Wait(0)

        local eventCount = GetNumberOfEvents(0)
        for eventIndex = 0, eventCount - 1 do
            local eventHash = Citizen.InvokeNative(GET_EVENT_AT_INDEX_NATIVE, 0, eventIndex)
            local handler = gameEventHandlers[eventHash]

            if handler then
                handler(eventIndex)
            end
        end
    end
end)

-- AddEventHandler('bcc-wagons:WagonMonitor', function()
--     wagonMonitorGeneration = wagonMonitorGeneration + 1
--     local generation = wagonMonitorGeneration
--     local monitoredWagon = MyWagon

--     CreateThread(function()
--         local saveInterval = tonumber(Config.care.saveIntervalMinutes)
--         local baseInterval = saveInterval and saveInterval > 0
--             and saveInterval * MINUTES_TO_MS
--             or DEFAULT_WAGON_SAVE_INTERVAL_MS
--         local countdown = baseInterval

--         while generation == wagonMonitorGeneration
--             and IsMyWagonActive
--             and MyWagon == monitoredWagon
--         do
--             Wait(WAGON_SAVE_CHECK_INTERVAL_MS)

--             if generation ~= wagonMonitorGeneration
--                 or not IsMyWagonActive
--                 or MyWagon ~= monitoredWagon
--             then
--                 break
--             end

--             if countdown <= 0 then
--                 if not IsWagonFleeingState and not IsInteractingWithWagon then
--                     SaveWagonStats(InWrithe)
--                 end

--                 countdown = baseInterval
--             else
--                 countdown = countdown - WAGON_SAVE_CHECK_INTERVAL_MS
--             end
--         end
--     end)
-- end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    ClearPedTasksImmediately(PlayerPedId())
    DisplayRadar(true)

    deleteEntity(ShopEntity)
    deleteEntity(MyEntity)
    deleteEntity(MyWagon)
    ShopEntity = 0
    MyEntity = 0
    MyWagon = 0

    for _, siteCfg in pairs(Sites) do
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        if siteCfg.NPC then
            deleteEntity(siteCfg.NPC)
            siteCfg.NPC = nil
        end
    end
end)
