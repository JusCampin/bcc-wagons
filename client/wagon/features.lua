local TAG_UPDATE_INTERVAL_MS = 1000
local DEFAULT_TAG_DISTANCE = 15.0

local NATIVE_CREATE_MP_GAMER_TAG_ON_ENTITY = 0xE961BF23EAB76B12
local NATIVE_SET_MP_GAMER_TAG_TOP_ICON = 0x5F57522BC1EB9D9D
local NATIVE_SET_MP_GAMER_TAG_VISIBILITY = 0x93171DDDAB274EB8
local NATIVE_IS_MP_GAMER_TAG_ACTIVE_ON_ENTITY = 0x502E1591A504F843
local NATIVE_REMOVE_MP_GAMER_TAG = 0x839BFD7D7E49FE09
local NATIVE_IS_PED_ON_SPECIFIC_VEHICLE = 0xEC5F66E459AF3BB2
local wagonTagGeneration = 0

local function isValidEntity(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

local function getSubmergedLevel(entity)
    return tonumber(GetEntitySubmergedLevel(entity)) or 0.0
end

local function setWagonTagVisibility(gamerTagId, isVisible)
    Citizen.InvokeNative(NATIVE_SET_MP_GAMER_TAG_VISIBILITY, gamerTagId, isVisible and 3 or 0)
end

local function removeWagonTag(gamerTagId)
    Citizen.InvokeNative(NATIVE_REMOVE_MP_GAMER_TAG, Citizen.PointerValueIntInitialized(gamerTagId))
end

local function shouldDisplayWagonTag(playerPed, wagon, maxDistanceSquared)
    if Citizen.InvokeNative(NATIVE_IS_PED_ON_SPECIFIC_VEHICLE, playerPed, MyWagon) then
        return false
    end

    local offset = GetEntityCoords(playerPed) - GetEntityCoords(wagon)
    local distanceSquared = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z
    return distanceSquared < maxDistanceSquared
end

-- Set the active wagon tag to display the wagon's name and health bar above the entity.
AddEventHandler('bcc-wagons:WagonTag', function()
    wagonTagGeneration = wagonTagGeneration + 1

    local generation = wagonTagGeneration
    local wagon = MyWagon
    if not isValidEntity(wagon) then return end

    local tagDistance = tonumber(Config.wagonTag.distance) or DEFAULT_TAG_DISTANCE
    local maxDistanceSquared = tagDistance * tagDistance
    local gamerTagId = Citizen.InvokeNative(NATIVE_CREATE_MP_GAMER_TAG_ON_ENTITY, wagon, WagonName)

    Citizen.InvokeNative(NATIVE_SET_MP_GAMER_TAG_TOP_ICON, gamerTagId, `WAGON`)

    -- nil forces the first update to explicitly apply the native's visibility state.
    local isTagVisible
    while generation == wagonTagGeneration
        and IsMyWagonActive
        and MyWagon == wagon
        and isValidEntity(wagon)
    do
        local shouldShow = shouldDisplayWagonTag(PlayerPedId(), wagon, maxDistanceSquared)

        if shouldShow ~= isTagVisible then
            if shouldShow
                or Citizen.InvokeNative(NATIVE_IS_MP_GAMER_TAG_ACTIVE_ON_ENTITY, gamerTagId, wagon)
            then
                setWagonTagVisibility(gamerTagId, shouldShow)
            end

            isTagVisible = shouldShow
        end

        Wait(TAG_UPDATE_INTERVAL_MS)
    end

    removeWagonTag(gamerTagId)
end)

-- Clean the active wagon once whenever it crosses into sufficiently deep water.
CreateThread(function()
    local waterCleaning = Config.care and Config.care.waterCleaning
    if not waterCleaning or waterCleaning.enabled == false then return end

    local minimumLevel = math.max(0.0, math.min(1.0, tonumber(waterCleaning.minimumSubmergedLevel) or 0.35))
    local checkInterval = math.max(100, math.floor(tonumber(waterCleaning.checkIntervalMs) or 500))
    local trackedWagon = 0
    local wasInDeepWater = false

    while true do
        local wagon = MyWagon

        if isValidEntity(wagon) and not IsEntityDead(wagon) then
            if wagon ~= trackedWagon then
                trackedWagon = wagon
                wasInDeepWater = false
            end

            local isInDeepWater = IsEntityInWater(wagon)
                and getSubmergedLevel(wagon) >= minimumLevel

            if isInDeepWater and not wasInDeepWater then
                CleanWagonAppearance(wagon)
            end

            wasInDeepWater = isInDeepWater
        else
            trackedWagon = 0
            wasInDeepWater = false
        end

        Wait(checkInterval)
    end
end)
