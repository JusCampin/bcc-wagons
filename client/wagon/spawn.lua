local SendingWagon = nil
local IsSelectedWagonRequestActive = false
local ARRIVAL_DISTANCE = 10.0

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

    local function requestWagonData()
        Core.Callback.TriggerAsync('bcc-wagons:GetSelectedWagonData', function(result)
            IsSelectedWagonRequestActive = false

            if not result then
                releaseShopDelivery(spawnOptions)
                DBG:Warning('No active selected-wagon profile returned from server!')
                return
            end

            SpawnWagon(result, spawnOptions)
        end, wagonId and { wagonId = tonumber(wagonId) } or nil)
    end

    local siteId = type(spawnOptions) == 'table' and spawnOptions.shopSite
    local shopSite = siteId and Sites[siteId]
    if not shopSite then
        requestWagonData()
        return
    end

    Core.NotifyRightTip(_U('wagonPreparing'), 3000)
    Core.Callback.TriggerAsync('bcc-wagons:ReserveShopDelivery', function(reservation)
        if type(reservation) ~= 'table' or not reservation.token then
            IsSelectedWagonRequestActive = false
            Core.NotifyRightTip(_U('shopBusy'), 4000)
            return
        end

        spawnOptions.deliveryToken = reservation.token
        spawnOptions.deliveryDestination = getShopDeliveryDestination(shopSite)
        requestWagonData()
    end, siteId)
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

    TaskGoToEntity(wagon, playerPed, -1, 10.2, 2.0, 0.0, 0)

    while SendingWagon == wagon and MyWagon == wagon and wagonExists(wagon) do
        Wait(0)
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(wagon))
        if distance <= ARRIVAL_DISTANCE then
            ClearPedTasks(wagon)
            break
        end
    end

    if SendingWagon == wagon then SendingWagon = nil end
end

local function sendWagonToPlayer(wagon)
    SendingWagon = wagon
    CreateThread(sendWagon)
end

local function calculateSpawnPosition(playerPed)
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -10.0, 0.0))

    -- Search for an established trail or road node first
    for i = 0, 24, 3 do
        local nodeCheck, node = GetNthClosestVehicleNode(x, y, z, i, 1, 1077936128, 0)
        if nodeCheck and node ~= vector3(0, 0, 0) then
            return node
        end
    end

    -- Fallback to scanning the open ground if no road node is nearby
    local maxScan = 1000
    local maxScanDown = 300
    for offset = maxScan, -maxScanDown, -1 do
        local groundCheck, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z + offset)
        if groundCheck then
            return vector3(x, y, groundZ)
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
    local spawnPosition = shopSpawn and shopSpawn.coords or calculateSpawnPosition(playerPed)
    if not spawnPosition then
        DBG:Error('Failed to find a valid ground or node position for wagon spawn.')
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

    InitializeHuntingWagon(wagon)
    CreateThread(function()
        local huntingSettings = Config.huntingWagon or {}
        local tarpDelay = math.max(0, tonumber(huntingSettings.tarpInitializationDelayMs) or 500)
        Wait(tarpDelay * 2 + 100)
        if MyWagon == wagon and wagonExists(wagon) then RefreshHuntingCargo() end
    end)

    --TriggerEvent('bcc-wagons:TradeWagon')
    TriggerEvent('bcc-wagons:WagonPrompts')

    finishSpawning()

    if shopSpawn then
        revealShopDeliveryWagon(wagon, shopSpawn, spawnOptions)
    else
        sendWagonToPlayer(wagon)
    end
end
