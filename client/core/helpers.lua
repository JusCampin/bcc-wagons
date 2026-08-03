local isLightingThreadRunning = false
local isWagonEntitySyncRunning = false
local pendingWagonEntityNetId = nil

local DEFAULT_TIMEOUT_MS = 5000
local ENTITY_REGISTRATION_TIMEOUT_MS = 500
local WAGON_SYNC_ATTEMPTS = 30
local WAGON_SYNC_INTERVAL_MS = 500
local NETWORK_CONTROL_RETRY_MS = 100
local UNEMPLOYED_JOB = 'unemployed'

local function getCharacterJob()
    local character = LocalPlayer.state.Character
    if not character then return nil, 0 end

    return character.Job or UNEMPLOYED_JOB, tonumber(character.Grade) or 0
end

local function hasRequiredGrade(jobGrades, job, grade)
    local jobConfig = jobGrades and jobGrades[job]
    local requiredGrade = type(jobConfig) == 'table' and jobConfig.minimumGrade or jobConfig
    return requiredGrade ~= nil and grade >= requiredGrade
end

---Internal helper to check if the player's active job matches the wainwright criteria
---@return boolean
local function hasWainwrightJobRequirements()
    local job, grade = getCharacterJob()
    return job ~= nil and hasRequiredGrade(Config.training.trainerJobs, job, grade)
end

---Checks if a player is blocked from accessing the current stable node
---@return boolean -- True if the player is BLOCKED, False if they are allowed in
function IsPlayerBlockedFromCurrentWainwrightShop()
    local currentShopNode = Sites[Site]

    if not currentShopNode or not currentShopNode.wainwrightBuy then
        return false
    end

    return not hasWainwrightJobRequirements()
end

-- Job check for general stable access and available wagons
function CheckPlayerJob(siteId)
    JobMatchedWagons = {}

    local activeJob, activeGrade = getCharacterJob()
    if not activeJob then return false end

    local shopNode = Sites[siteId]
    if not shopNode then return false end

    local shop = shopNode.shop
    local isAuthorized = hasRequiredGrade(shop and shop.jobs, activeJob, activeGrade)

    if activeJob ~= UNEMPLOYED_JOB then
        JobMatchedWagons = Wagons.ModelJobLocks and Wagons.ModelJobLocks.Jobs and Wagons.ModelJobLocks.Jobs[activeJob] or {}
    end

    if shop and shop.jobsEnabled and not isAuthorized then
        Core.NotifyRightTip(_U('needJob') or 'You do not have the required job to access this shop!', 4000)
        return false
    end

    return true
end

---@param targetNetId number
RegisterNetEvent('bcc-wagons:UpdateMyWagonEntity', function(targetNetId)
    if not targetNetId or targetNetId == 0 then return end

    pendingWagonEntityNetId = targetNetId
    if isWagonEntitySyncRunning then return end

    isWagonEntitySyncRunning = true

    CreateThread(function()
        while pendingWagonEntityNetId do
            local netId = pendingWagonEntityNetId
            pendingWagonEntityNetId = nil
            local isEntityFound = false
            local remainingAttempts = WAGON_SYNC_ATTEMPTS

            while remainingAttempts > 0 do
                if pendingWagonEntityNetId and pendingWagonEntityNetId ~= netId then
                    break
                end

                if NetworkDoesNetworkIdExist(netId) then
                    local resolvedEntity = NetworkGetEntityFromNetworkId(netId)

                    if resolvedEntity and resolvedEntity ~= 0 and DoesEntityExist(resolvedEntity) then
                        MyWagon = resolvedEntity
                        local entityState = Entity(resolvedEntity).state
                        MyWagonId = (entityState and entityState.myWagonId) or MyWagonId
                        IsWagonFleeingState = false
                        isEntityFound = true

                        if pendingWagonEntityNetId == netId then
                            pendingWagonEntityNetId = nil
                        end

                        DBG:Info('Wagon entity handle successfully re-synchronized across server-instance boundaries: ', resolvedEntity)
                        break
                    end
                end

                remainingAttempts = remainingAttempts - 1
                Wait(WAGON_SYNC_INTERVAL_MS)
            end

            if not isEntityFound and not pendingWagonEntityNetId then
                DBG:Warning('Instance Sync Timeout: The mount asset entity failed to stream back into local client RAM.')
            end
        end

        isWagonEntitySyncRunning = false
    end)
end)

function GetControlOfWagon(timeoutMs)
    local wagon = MyWagon
    if not wagon or wagon == 0 or not DoesEntityExist(wagon) then return false end

    local timeout = tonumber(timeoutMs) or DEFAULT_TIMEOUT_MS
    local startTime = GetGameTimer()

    while MyWagon == wagon and DoesEntityExist(wagon) do
        if NetworkHasControlOfEntity(wagon) then
            return true
        end

        if GetGameTimer() - startTime >= timeout then
            break
        end

        NetworkRequestControlOfEntity(wagon)
        Wait(NETWORK_CONTROL_RETRY_MS)
    end

    if MyWagon ~= wagon or not DoesEntityExist(wagon) then
        return false
    end

    DBG:Warning('Timed out while requesting network control of the active wagon.')
    return false
end

function LoadModel(model, modelName)
    if not IsModelValid(model) then
        DBG:Error('Invalid wagon model:', modelName)
        return false
    end

    if not HasModelLoaded(model) then
        RequestModel(model)

        local startTime = GetGameTimer()

        while not HasModelLoaded(model) do
            if GetGameTimer() - startTime > DEFAULT_TIMEOUT_MS then
                DBG:Error('Failed to load wagon model:', modelName)
                return false
            end
            Wait(0)
        end
    end

    return true
end

---Remove dirt, decals, and blood without removing the wagon's wet appearance.
---@param wagon integer
---@return boolean cleaned
function CleanWagonAppearance(wagon)
    if not wagon or wagon == 0 or not DoesEntityExist(wagon) then
        return false
    end

    -- TODO: Consider adding a native to clear wagon dirt and decals without affecting wetness.
    -- Citizen.InvokeNative(0x6585D955A68452A5, wagon) -- ClearPedEnvDirt
    -- Citizen.InvokeNative(0x523C79AEEFCC4A2A, wagon, 10, 'ALL') -- ClearPedDamageDecalByZone
    -- Citizen.InvokeNative(0x8FE22675A5A45817, wagon) -- ClearPedBloodDamage
    return true
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    local startTime = GetGameTimer()

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() - startTime > DEFAULT_TIMEOUT_MS then
            DBG:Error(('Failed to load animation dictionary: %s'):format(dict))
            return false
        end
        Wait(0)
    end
    return true
end

function CheckEntityExists(entity)
    if not entity or entity == 0 then
        DBG:Error('Entity instantiation failed immediately. Invalid entity handle received.')
        return false
    end

    if DoesEntityExist(entity) then
        return true
    end

    local startTime = GetGameTimer()

    while not DoesEntityExist(entity) do
        if GetGameTimer() - startTime > ENTITY_REGISTRATION_TIMEOUT_MS then
            DBG:Error(('Entity registration timed out. Handle ID: %s'):format(entity))
            return false
        end
        Wait(0)
    end

    return true
end

function GetClosestPlayer()
    local players = GetActivePlayers()
    local localPlayer = PlayerId()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, playerId in ipairs(players) do
        if playerId ~= localPlayer then
            local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
            local distance = #(playerCoords - targetCoords)
            if distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

---@param onSuccess function
---@param onFailure function|nil
function FetchRosterAndAction(onSuccess, onFailure)
    Core.Callback.TriggerAsync('bcc-wagons:GetMyWagonsData', function(wagonData)
        if wagonData then
            MyWagonsData = wagonData

            if type(onSuccess) == 'function' then
                onSuccess(wagonData)
            end
        else
            DBG:Warning('Failed to retrieve wagon roster from server!')
            MyWagonsData = {}

            if type(onFailure) == 'function' then
                onFailure()
            end
        end
    end)
end

--- Update the locally selected wagon and optionally persist the selection.
---@param wagonId number|string
---@param persist boolean|nil
---@return boolean
function SetSelectedWagonLocally(wagonId, persist)
    local selectedWagonId = tonumber(wagonId)
    if not selectedWagonId then return false end

    MyWagonId = selectedWagonId

    if MyWagonsData then
        for _, wagon in ipairs(MyWagonsData) do
            wagon.is_selected = tonumber(wagon.id) == selectedWagonId
        end
    end

    if persist then
        TriggerServerEvent('bcc-wagons:SelectActiveWagon', selectedWagonId)
    end

    return true
end

function CameraLighting()
    if isLightingThreadRunning then return end
    isLightingThreadRunning = true

    CreateThread(function()
        local preview = ShopUI.GetPreviewWagonConfig()
        if not preview then
            isLightingThreadRunning = false
            return
        end
        local coords = preview.coords

        while Cam do
            Wait(0)
            Citizen.InvokeNative(0xD2D9E04C0DF927F4, coords.x, coords.y, coords.z + 3.0, 130, 130, 85, 4.0, 15.0) -- DrawLightWithRange
        end

        isLightingThreadRunning = false
    end)
end
