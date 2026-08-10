local SendingWagon = nil
local IsSelectedWagonRequestActive = false
local ARRIVAL_DISTANCE = 10.0
local GET_PED_IN_DRAFT_HARNESS <const> = 0xA8BA0BAE0173457B
local MAX_DRAFT_ANIMALS <const> = 4
local TASK_VEHICLE_DRIVE_TO_POINT_2 <const> = 0x6524A8981E8BE7C9
local calculateSpawnPosition

local DraftAnimalGroups = {
    -- Regional Draft Horse Groups
    DRAFT_HORSES_SOUTHERN   = 3190104953,
    DRAFT_HORSES_NORTHERN   = 3016566292,
    DRAFT_HORSES_WESTERN    = 4244744145,
    -- Socioeconomic & Industrial Groups
    DRAFT_HORSES_POOR       = 3204433874,
    DRAFT_HORSES_MID        = 2961454031,
    DRAFT_HORSES_RICH       = 408782868,
    -- Specialized Functional Groups
    DRAFT_HORSES_FARM       = 1994583957,
    DRAFT_HORSES_STAGECOACH = 532181714
}

local function wagonExists(wagon)
    return wagon and wagon ~= 0 and DoesEntityExist(wagon)
end

local function deleteWagonEntity(wagon)
    if not wagonExists(wagon) then return end

    SetEntityAsMissionEntity(wagon, true, true)
    DeleteEntity(wagon)
end

local function setWagonStateNetId(netId)
    local wagonData = LocalPlayer.state.WagonData or {}
    wagonData.MyWagon = netId or 0
    LocalPlayer.state.WagonData = wagonData
end

local function finishSpawning(model)
    if model then SetModelAsNoLongerNeeded(model) end
    IsSpawningWagonActive = false
end

local function releaseShopDelivery(spawnOptions)
    if type(spawnOptions) ~= 'table' or not spawnOptions.deliveryToken then return end
    TriggerServerEvent(
        'bcc-wagons:ReleaseShopDelivery',
        spawnOptions.shopSite,
        spawnOptions.deliveryToken
    )
    spawnOptions.deliveryToken = nil
end

local function getShopDeliveryDestination(shopSite)
    local configured = shopSite and shopSite.wagon and shopSite.wagon.delivery
    if configured then return configured end

    return GetEntityCoords(PlayerPedId())
end

local function getHeadingToward(fromCoords, destination, fallbackHeading)
    if not fromCoords or not destination then return fallbackHeading end

    local deltaX = destination.x - fromCoords.x
    local deltaY = destination.y - fromCoords.y
    if math.abs(deltaX) < 0.001 and math.abs(deltaY) < 0.001 then return fallbackHeading end

    -- RedM headings increase clockwise: +X (east) is 270 degrees, not 90.
    local heading = math.deg(math.atan(-deltaX, deltaY))
    return (heading + 360.0) % 360.0
end

local function startShopDelivery(wagon, shopSpawn, spawnOptions)
    local destination = spawnOptions.deliveryDestination
    if not destination then
        releaseShopDelivery(spawnOptions)
        return
    end

    local settings = Config.shop.delivery or {}
    local speed = tonumber(settings.walkSpeed) or 1.25
    local arrivalDistance = tonumber(settings.arrivalDistance) or 2.5
    local routeHeading = getHeadingToward(shopSpawn.coords, destination, shopSpawn.heading)
    TaskGoStraightToCoord(
        wagon,
        destination.x,
        destination.y,
        destination.z,
        speed,
        -1,
        tonumber(destination.w) or routeHeading,
        arrivalDistance
    )

    CreateThread(function()
        local clearance = tonumber(settings.spawnClearance) or 4.0
        local timeout = math.max(5000, tonumber(settings.reservationTimeoutMs) or 15000)
        local deadline = GetGameTimer() + timeout

        while wagonExists(wagon) and GetGameTimer() < deadline do
            if #(GetEntityCoords(wagon) - shopSpawn.coords) >= clearance then break end
            Wait(250)
        end

        releaseShopDelivery(spawnOptions)
    end)
end

local function revealShopDeliveryWagon(wagon, shopSpawn, spawnOptions)
    CreateThread(function()
        -- Newly created wagon models briefly use an uninitialized pose while
        -- their variation and physics state settle.
        SetEntityAlpha(wagon, 0, false)
        SetEntityVisible(wagon, false, false)
        Wait(400)

        if MyWagon ~= wagon or not wagonExists(wagon) then
            releaseShopDelivery(spawnOptions)
            return
        end

        SetEntityVisible(wagon, true, false)
        SetEntityAlpha(wagon, 0, false)
        startShopDelivery(wagon, shopSpawn, spawnOptions)

        for alpha = 40, 240, 40 do
            if MyWagon ~= wagon or not wagonExists(wagon) then return end
            SetEntityAlpha(wagon, alpha, false)
            Wait(30)
        end

        if MyWagon == wagon and wagonExists(wagon) then ResetEntityAlpha(wagon) end
    end)
end

local function isShopSpawnClear(coords, radius)
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle)
            and #(GetEntityCoords(vehicle) - coords) < radius then
            return false
        end
    end
    return true
end

---@param wagonId number|string|nil
---@param spawnOptions table|nil
function GetSelectedWagon(wagonId, spawnOptions)
    if IsSelectedWagonRequestActive or IsSpawningWagonActive then return end
    IsSelectedWagonRequestActive = true

    Core.Callback.TriggerAsync('bcc-wagons:GetSelectedWagonData', function(result)
        if not result then
            IsSelectedWagonRequestActive = false
            releaseShopDelivery(spawnOptions)
            DBG:Warning('No active selected-wagon profile returned from server!')
            return
        end

        local siteId = type(spawnOptions) == 'table' and spawnOptions.shopSite
        local shopSite = siteId and Sites[siteId]
        if not shopSite then
            IsSelectedWagonRequestActive = false
            SpawnWagon(result, spawnOptions)
            return
        end

        -- Do not announce or reserve a delivery until ownership has been
        -- confirmed. This avoids "Preparing" followed by "no wagon".
        Core.NotifyRightTip(_U('wagonPreparing'), 3000)
        Core.Callback.TriggerAsync('bcc-wagons:ReserveShopDelivery', function(reservation)
            IsSelectedWagonRequestActive = false
            if type(reservation) ~= 'table' or not reservation.token then
                Core.NotifyRightTip(_U('shopBusy'), 4000)
                return
            end

            spawnOptions.deliveryToken = reservation.token
            spawnOptions.deliveryDestination = getShopDeliveryDestination(shopSite)
            SpawnWagon(result, spawnOptions)
        end, siteId)
    end, wagonId and { wagonId = tonumber(wagonId) } or nil)
end

local function getDraftAnimals(wagon)
    local animals = {}
    for index = 0, MAX_DRAFT_ANIMALS - 1 do
        local animal = Citizen.InvokeNative(GET_PED_IN_DRAFT_HARNESS, wagon, index)
        if animal and animal ~= 0 and DoesEntityExist(animal) then
            animals[#animals + 1] = animal
        end
    end
    return animals
end

---@param siteId string
function CallActiveWagonAtShop(siteId)
    if not Sites[siteId] then return false end
    GetSelectedWagon(nil, { shopSite = siteId })
    return true
end

---@param wagonId number|string
---@param siteId string
function ManageWagonAtShop(wagonId, siteId)
    local selectedWagonId = tonumber(wagonId)
    local spawnedWagonId = tonumber(MyWagonId)
    if not selectedWagonId or not Sites[siteId] then return false end

    CreateThread(function()
        local wagonIsOut = wagonExists(MyWagon)
        if wagonIsOut then ReturnWagon(spawnedWagonId ~= selectedWagonId) end

        ShopMenu:Close()
        Wait(450)

        if not wagonIsOut or spawnedWagonId ~= selectedWagonId then
            SetSelectedWagonLocally(selectedWagonId, false)
            GetSelectedWagon(selectedWagonId, { shopSite = siteId })
        end
    end)
    return true
end

local function sendWagon()
    local playerPed = PlayerPedId()
    local wagon = MyWagon

    if not wagonExists(wagon) then
        SendingWagon = nil
        return
    end

    local draftAnimals = getDraftAnimals(wagon)
    NetworkRequestControlOfEntity(wagon)
    local controlDeadline = GetGameTimer() + 1000
    while not NetworkHasControlOfEntity(wagon) and GetGameTimer() < controlDeadline do
        Wait(0)
        NetworkRequestControlOfEntity(wagon)
    end

    if not NetworkHasControlOfEntity(wagon) then
        DBG:Warning('Unable to call wagon: network control request failed.')
        SendingWagon = nil
        return
    end

    local callSettings = Config.shop.callActiveWagon or {}
    local speed = tonumber(callSettings.driveSpeed) or 3.0
    local target = calculateSpawnPosition(playerPed)

    local function relocateToRoad(reason)
        if callSettings.relocateIfDriveFails ~= true then
            DBG:Warning(('Call wagon stopped: %s'):format(reason))
            return false
        end

        local wagonId = MyWagonId
        DBG:Info(('Call wagon: %s; re-summoning on a clear road/trail node.'):format(reason))
        SendingWagon = nil
        -- This replacement is already the terminal road-safe fallback. Do not
        -- start another call movement task after it spawns, or a blocked area
        -- can recurse through an endless spawn -> stuck -> spawn loop.
        GetSelectedWagon(wagonId, { skipCallMovement = true })
        return true
    end

    if not target then
        relocateToRoad('no clear approach node was found')
        return
    end

    -- This native drives directly rather than planning a road route. Use it
    -- only when the road/trail node near the player has a clear approach.
    if not HasEntityClearLosToCoord(wagon, target.x, target.y, target.z, 17) then
        relocateToRoad('the direct approach was obstructed')
        return
    end

    Citizen.InvokeNative(
        TASK_VEHICLE_DRIVE_TO_POINT_2,
        wagon,
        target.x,
        target.y,
        target.z,
        speed,
        0.25,
        0
    )
    DBG:Info('Call wagon: driving to a clear road/trail node near the player.')

    local progressPosition = GetEntityCoords(wagon)
    local progressCheckAt = GetGameTimer()
        + math.max(1000, tonumber(callSettings.stuckCheckMs) or 1500)

    while SendingWagon == wagon and MyWagon == wagon and wagonExists(wagon) do
        Wait(50)
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(wagon))
        if distance <= ARRIVAL_DISTANCE then
            for _, animal in ipairs(draftAnimals) do
                if DoesEntityExist(animal) then ClearPedTasks(animal) end
            end
            break
        end

        if GetGameTimer() >= progressCheckAt then
            local currentPosition = GetEntityCoords(wagon)
            local movement = #(currentPosition - progressPosition)
            if movement < 0.5 then
                if relocateToRoad('the wagon became stuck') then return end
                break
            end
            progressPosition = currentPosition
            progressCheckAt = GetGameTimer()
                + math.max(1000, tonumber(callSettings.stuckCheckMs) or 1500)
        end
    end

    if SendingWagon == wagon then SendingWagon = nil end
end

local function sendWagonToPlayer(wagon)
    SendingWagon = wagon
    CreateThread(sendWagon)
end

-- Calls the currently active wagon. An existing wagon travels to the player;
-- otherwise the character's selected owned wagon is spawned nearby.
function CallActiveWagon()
    if SendingWagon or IsSelectedWagonRequestActive or IsSpawningWagonActive then return false end

    if wagonExists(MyWagon) then
        sendWagonToPlayer(MyWagon)
    else
        -- Initial J summon already spawns at a clear road/trail node near the
        -- player. Movement is only for a wagon that was already active.
        GetSelectedWagon(nil, { skipCallMovement = true })
    end
    return true
end

local function isCallSpawnClear(coords, radius, playerPed)
    local pools = { 'CVehicle', 'CObject', 'CPed' }
    for _, poolName in ipairs(pools) do
        for _, entity in ipairs(GetGamePool(poolName)) do
            if entity ~= playerPed
                and DoesEntityExist(entity)
                and #(GetEntityCoords(entity) - coords) < radius then
                return false
            end
        end
    end
    return true
end

calculateSpawnPosition = function(playerPed)
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -10.0, 0.0))
    local callSettings = Config.shop.callActiveWagon or {}
    local clearance = math.max(2.0, tonumber(callSettings.spawnClearance) or 5.0)
    local searchNodes = math.max(1, math.floor(tonumber(callSettings.roadSearchNodes) or 30))

    -- Search actual vehicle-path nodes and retain their road heading. Checking
    -- clearance rejects service nodes inside yards, sheds, fences, or traffic.
    for index = 0, searchNodes - 1 do
        local found, node, heading = GetNthClosestVehicleNodeWithHeading(
            x,
            y,
            z,
            index,
            9,
            3.0,
            2.5
        )
        if found
            and node ~= vector3(0, 0, 0)
            and isCallSpawnClear(node, clearance, playerPed) then
            return node, heading
        end
    end

    if callSettings.spawnOnRoadOnly == true then return nil end

    -- Fallback to scanning the open ground if no road node is nearby
    local maxScan = 1000
    local maxScanDown = 300
    for offset = maxScan, -maxScanDown, -1 do
        local groundCheck, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z + offset)
        if groundCheck then
            return vector3(x, y, groundZ), GetEntityHeading(playerPed)
        end
    end

    return nil
end

function SpawnWagon(data, spawnOptions)
    if IsSpawningWagonActive then
        releaseShopDelivery(spawnOptions)
        return
    end
    IsSpawningWagonActive = true
    SendingWagon = nil

    if type(data) ~= 'table' or not data.model then
        DBG:Error('Cannot spawn wagon: invalid wagon data received.')
        releaseShopDelivery(spawnOptions)
        finishSpawning()
        return
    end

    deleteWagonEntity(MyWagon)
    MyWagon = 0

    local wagonStateBag = LocalPlayer.state.WagonData
    local oldNetId = wagonStateBag and wagonStateBag.MyWagon

    if oldNetId and oldNetId ~= 0 and NetworkDoesNetworkIdExist(oldNetId) then
        local historicalEntity = NetworkGetEntityFromNetworkId(oldNetId)

        if wagonExists(historicalEntity) then
            deleteWagonEntity(historicalEntity)
            DBG:Info('State Bag Purge: Removed old wagon NetID reference.')
        end
    end
    setWagonStateNetId(0)

    MyWagonId = data.id
    WagonName = data.name
    local modelName = data.model
    local modelHash = joaat(modelName)

    if not LoadModel(modelHash, modelName) then
        DBG:Error('Failed to load wagon model:', data.model)
        releaseShopDelivery(spawnOptions)
        finishSpawning()
        return
    end

    local parentMappingData = Wagons.ModelToTypeMap and Wagons.ModelToTypeMap[modelName]
    MyWagonType = parentMappingData and parentMappingData.wagonType or 'Unknown'

    MyWagonModel = modelName

    local player = PlayerId()
    local playerPed = PlayerPedId()

    local shopSite = type(spawnOptions) == 'table' and Sites[spawnOptions.shopSite]
    local shopSpawn = shopSite and shopSite.wagon
    local calculatedHeading
    local spawnPosition
    if shopSpawn then
        spawnPosition = shopSpawn.coords
    else
        spawnPosition, calculatedHeading = calculateSpawnPosition(playerPed)
    end
    if not spawnPosition then
        DBG:Error('Failed to find a clear road node for wagon spawn.')
        releaseShopDelivery(spawnOptions)
        finishSpawning(modelHash)
        return
    end

    if shopSpawn then
        local clearance = tonumber((Config.shop.delivery or {}).spawnClearance) or 4.0
        local deadline = GetGameTimer() + 5000

        while not isShopSpawnClear(spawnPosition, clearance) and GetGameTimer() < deadline do Wait(250) end

        if not isShopSpawnClear(spawnPosition, clearance) then
            DBG:Warning(('Shop spawn remained obstructed at site: %s'):format(tostring(spawnOptions.shopSite)))
            Core.NotifyRightTip(_U('shopExitObstructed'), 4000)
            releaseShopDelivery(spawnOptions)
            finishSpawning(modelHash)
            return
        end
    end

    local spawnHeading = shopSpawn
        and getHeadingToward(shopSpawn.coords, spawnOptions.deliveryDestination, shopSpawn.heading)
        or calculatedHeading
        or GetEntityHeading(playerPed)

    local wagon = CreateDraftVehicle(
        modelHash,
        spawnPosition.x,
        spawnPosition.y,
        spawnPosition.z,
        spawnHeading,
        true,
        false,
        false,
        DraftAnimalGroups.DRAFT_HORSES_RICH,
        false
    )

    if not CheckEntityExists(wagon) then
        DBG:Error('Failed to spawn wagon.')
        releaseShopDelivery(spawnOptions)
        finishSpawning(modelHash)
        return
    end

    MyWagon = wagon
    SetModelAsNoLongerNeeded(modelHash)

    if shopSpawn then
        SetEntityAlpha(wagon, 0, false)
        SetEntityVisible(wagon, false, false)
    end

    if not NetworkGetEntityIsNetworked(wagon) then
        NetworkRegisterEntityAsNetworked(wagon)
    end

    local netId = NetworkGetNetworkIdFromEntity(wagon)
    if netId and netId ~= 0 then
        setWagonStateNetId(netId)
    else
        DBG:Error('Failed to generate a synchronized NetID for the spawned wagon!')
        setWagonStateNetId(0)
    end

    -- Base Wagon Initialization Natives
    Citizen.InvokeNative(0x7263332501E07F52, wagon, 0) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0xD0E02AA618020D17, PlayerId(), MyWagon) -- SetPlayerOwnsVehicle
    Citizen.InvokeNative(0xE2487779957FE897, MyWagon, 528) -- SetTransportUsageFlags

    -- Blip Registration
    if Config.wagonBlip.enabled then
        local wagonBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, wagon) -- BlipAddForEntity
        SetBlipSprite(wagonBlip, joaat(Config.wagonBlip.sprite), true)
        Citizen.InvokeNative(0x9CB1A1623062F402, wagonBlip, WagonName) -- SetBlipName
    end

    TriggerServerEvent('bcc-wagons:RegisterInventory', MyWagonId)
    Entity(wagon).state:set('myWagonId', MyWagonId, true)
    EmitWagonLifecycleEvent('bcc-wagons:client:wagonSpawned')

    --TriggerEvent('bcc-wagons:TradeWagon')
    TriggerEvent('bcc-wagons:WagonPrompts')

    finishSpawning()

    if shopSpawn then
        revealShopDeliveryWagon(wagon, shopSpawn, spawnOptions)
    elseif type(spawnOptions) ~= 'table' or spawnOptions.skipCallMovement ~= true then
        sendWagonToPlayer(wagon)
    end
end
