local NATIVE_GET_FIRST_ENTITY_PED_IS_CARRYING <const> = 0xD806CD2A4F2C2996
local NATIVE_TASK_PLACE_CARRIED_ENTITY_AT_COORD <const> = 0xC7F0B43DCDC57E3D
local NATIVE_PROMPT_HAS_HOLD_MODE_COMPLETED <const> = 0xE0F65F0640EF0617
local NATIVE_PROMPT_CONTEXT_SET_POINT <const> = 0xAE84C5EE2C384FB3
local NATIVE_PROMPT_CONTEXT_SET_RADIUS <const> = 0x0C718001B77CA468
local NATIVE_GET_CARCASS_QUALITY <const> = 0x88EFFED5FE8B0B4A
local NATIVE_IS_ANIMAL_SKINNED <const> = 0x88A5564B19C15391
local NATIVE_IS_ENTITY_FULLY_LOOTED <const> = 0x8DE41E9902E85756
local NATIVE_GET_PED_META_OUTFIT_HASH <const> = 0x30569F348D126A5A
local NATIVE_GET_NUM_COMPONENTS_IN_PED <const> = 0x90403E8107B60E81
local NATIVE_GET_META_PED_ASSET_GUIDS <const> = 0xA9C28516A6DC9D56
local NATIVE_GET_META_PED_ASSET_TINT <const> = 0xE7998FEC53A33BBE
local NATIVE_SET_META_PED_TAG <const> = 0xBC6DF00D7A4A6819
local NATIVE_FIX_PED_OUTFIT <const> = 0xAAB86462966168CE
local NATIVE_UPDATE_PED_VARIATION <const> = 0xCC8CA3E88256E58F
local NATIVE_SET_PED_QUALITY <const> = 0xCE6B874286D640BB
local NATIVE_SET_ENTITY_FULLY_LOOTED <const> = 0x6BCF5F3D8FFE988D
local HuntingLoadPrompt = 0
local HuntingUnloadPrompt = 0
local isLoadingCarcass = false
local huntingCargoUsed = 0
local huntingCargoCapacity = 1

local function entityExists(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

local function getCarcassMetaTags(carcass)
    local tags = {}
    local count = Citizen.InvokeNative(
        NATIVE_GET_NUM_COMPONENTS_IN_PED,
        carcass,
        Citizen.ResultAsInteger()
    )

    for index = 0, math.max(0, (tonumber(count) or 0) - 1) do
        local drawable, albedo, normal, material = Citizen.InvokeNative(
            NATIVE_GET_META_PED_ASSET_GUIDS,
            carcass,
            index,
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt()
        )
        local palette, tint0, tint1, tint2 = Citizen.InvokeNative(
            NATIVE_GET_META_PED_ASSET_TINT,
            carcass,
            index,
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt(),
            Citizen.PointerValueInt()
        )
        tags[#tags + 1] = {
            drawable = drawable,
            albedo = albedo,
            normal = normal,
            material = material,
            palette = palette,
            tint0 = tint0,
            tint1 = tint1,
            tint2 = tint2,
        }
    end
    return tags
end

local function applyCarcassMetaTags(carcass, tags)
    if type(tags) ~= 'table' then return 0 end
    local applied = 0
    for _, tag in pairs(tags) do
        if type(tag) == 'table' and tonumber(tag.drawable) then
            Citizen.InvokeNative(
                NATIVE_SET_META_PED_TAG,
                carcass,
                tonumber(tag.drawable) or 0,
                tonumber(tag.albedo) or 0,
                tonumber(tag.normal) or 0,
                tonumber(tag.material) or 0,
                tonumber(tag.palette) or 0,
                tonumber(tag.tint0) or 0,
                tonumber(tag.tint1) or 0,
                tonumber(tag.tint2) or 0
            )
            applied = applied + 1
        end
    end
    if applied > 0 then
        Citizen.InvokeNative(NATIVE_FIX_PED_OUTFIT, carcass, true)
        Citizen.InvokeNative(
            NATIVE_UPDATE_PED_VARIATION,
            carcass,
            false,
            true,
            true,
            true,
            false
        )
    end
    return applied
end

local function createLoadPrompt()
    if HuntingLoadPrompt ~= 0 then return end

    local settings = Config.huntingWagon or {}
    HuntingLoadPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(HuntingLoadPrompt, settings.loadPromptControl or 0x760A9C6F)
    UiPromptSetText(HuntingLoadPrompt, CreateVarString(10, 'LITERAL_STRING', _U('huntingCargoPrompt')))
    UiPromptSetVisible(HuntingLoadPrompt, true)
    UiPromptSetEnabled(HuntingLoadPrompt, true)
    UiPromptSetHoldMode(HuntingLoadPrompt, tonumber(settings.loadPromptHoldMs) or 1000)
    Citizen.InvokeNative(NATIVE_PROMPT_CONTEXT_SET_POINT, HuntingLoadPrompt, 0.0, 0.0, 0.0)
    Citizen.InvokeNative(
        NATIVE_PROMPT_CONTEXT_SET_RADIUS,
        HuntingLoadPrompt,
        tonumber(settings.interactionDistance) or 2.0
    )
    UiPromptRegisterEnd(HuntingLoadPrompt)

    HuntingUnloadPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(HuntingUnloadPrompt, settings.loadPromptControl or 0x760A9C6F)
    UiPromptSetText(HuntingUnloadPrompt, CreateVarString(10, 'LITERAL_STRING', _U('huntingCargoUnloadPrompt')))
    UiPromptSetVisible(HuntingUnloadPrompt, true)
    UiPromptSetEnabled(HuntingUnloadPrompt, true)
    UiPromptSetHoldMode(HuntingUnloadPrompt, tonumber(settings.loadPromptHoldMs) or 1000)
    Citizen.InvokeNative(NATIVE_PROMPT_CONTEXT_SET_POINT, HuntingUnloadPrompt, 0.0, 0.0, 0.0)
    Citizen.InvokeNative(
        NATIVE_PROMPT_CONTEXT_SET_RADIUS,
        HuntingUnloadPrompt,
        tonumber(settings.interactionDistance) or 2.0
    )
    UiPromptRegisterEnd(HuntingUnloadPrompt)
end

local function setHuntingPromptState(loadEnabled, unloadEnabled)
    UiPromptSetEnabled(HuntingLoadPrompt, loadEnabled)
    UiPromptSetVisible(HuntingLoadPrompt, loadEnabled)
    UiPromptSetEnabled(HuntingUnloadPrompt, unloadEnabled)
    UiPromptSetVisible(HuntingUnloadPrompt, unloadEnabled)
end

local function carriedDeadAnimal(playerPed)
    local carried = Citizen.InvokeNative(
        NATIVE_GET_FIRST_ENTITY_PED_IS_CARRYING,
        playerPed,
        Citizen.ResultAsInteger()
    )

    if not entityExists(carried) or not IsEntityAPed(carried) then return 0 end
    if IsPedAPlayer(carried) or IsPedHuman(carried) or not IsEntityDead(carried) then return 0 end
    return carried
end

local function huntingWagonRequest()
    if not IsActiveHuntingWagon() or not MyWagonId then return nil end
    local wagonNetId = NetworkGetNetworkIdFromEntity(MyWagon)
    if not wagonNetId or wagonNetId == 0 then return nil end
    return { wagonId = MyWagonId, wagonNetId = wagonNetId }
end

local function applyCargoStatus(status)
    if type(status) ~= 'table' then return end
    local used = math.max(0, tonumber(status.used) or 0)
    local capacity = math.max(1, tonumber(status.capacity) or 1)
    huntingCargoUsed = used
    huntingCargoCapacity = capacity
    SetHuntingWagonTarpHeight(used / capacity, false)
end

function RefreshHuntingCargo()
    local request = huntingWagonRequest()
    if not request then return end

    Core.Callback.TriggerAsync('bcc-wagons:GetHuntingCargoStatus', function(status)
        if not IsActiveHuntingWagon() then return end
        applyCargoStatus(status)
    end, request)
end

function ClearHuntingCargoForTesting()
    local request = huntingWagonRequest()
    if not request then return false end

    Core.Callback.TriggerAsync('bcc-wagons:ClearHuntingCargoForTesting', function(success, status)
        if not success then
            Core.NotifyRightTip(_U('huntingCargoLoadFailed'), 4000)
            return
        end
        applyCargoStatus(status)
        Core.NotifyRightTip('Hunting cargo cleared for testing.', 4000)
    end, request)
    return true
end

local function deleteLoadedCarcass(playerPed, carcass)
    local settings = Config.huntingWagon or {}
    local rear = settings.rearOffset or {}
    local destination = GetOffsetFromEntityInWorldCoords(
        MyWagon,
        tonumber(rear.x) or 0.0,
        tonumber(rear.y) or -2.25,
        tonumber(rear.z) or 0.0
    )

    Citizen.InvokeNative(
        NATIVE_TASK_PLACE_CARRIED_ENTITY_AT_COORD,
        playerPed,
        carcass,
        destination.x,
        destination.y,
        destination.z,
        1.0,
        0
    )
    Wait(math.max(500, tonumber(settings.loadAnimationMs) or 1600))

    if not entityExists(carcass) then return end
    NetworkRequestControlOfEntity(carcass)
    local deadline = GetGameTimer() + 1000
    while not NetworkHasControlOfEntity(carcass) and GetGameTimer() < deadline do
        Wait(0)
        NetworkRequestControlOfEntity(carcass)
    end

    SetEntityAsMissionEntity(carcass, true, true)
    DetachEntity(carcass, true, true)
    DeleteEntity(carcass)
end

local function loadCarcass(carcass)
    if isLoadingCarcass then return end
    local request = huntingWagonRequest()
    if not request then return end

    isLoadingCarcass = true
    local modelHash = GetEntityModel(carcass)
    local netId = NetworkGetNetworkIdFromEntity(carcass)
    request.modelHash = modelHash
    request.quality = Citizen.InvokeNative(
        NATIVE_GET_CARCASS_QUALITY,
        carcass,
        Citizen.ResultAsInteger()
    )
    local skinnedResult = Citizen.InvokeNative(
        NATIVE_IS_ANIMAL_SKINNED,
        carcass,
        Citizen.ResultAsInteger()
    )
    local restoredSkinnedState = NetworkGetEntityIsNetworked(carcass)
        and Entity(carcass).state.bccWagonSkinned == true
    local fullyLooted = Citizen.InvokeNative(
        NATIVE_IS_ENTITY_FULLY_LOOTED,
        carcass,
        Citizen.ResultAsInteger()
    )
    request.isSkinned = skinnedResult == true
        or tonumber(skinnedResult) == 1
        or fullyLooted == true
        or tonumber(fullyLooted) == 1
        or restoredSkinnedState
    request.metaTags = request.isSkinned and getCarcassMetaTags(carcass) or nil
    request.outfitHash = Citizen.InvokeNative(
        NATIVE_GET_PED_META_OUTFIT_HASH,
        carcass,
        Citizen.ResultAsInteger()
    )
    request.carcassKey = netId and netId ~= 0
        and ('net:%d'):format(netId)
        or ('local:%d:%d'):format(modelHash, carcass)

    Core.Callback.TriggerAsync('bcc-wagons:LoadHuntingCarcass', function(success, reason, status)
        if not success then
            Core.NotifyRightTip(
                reason == 'full' and _U('huntingCargoFull') or _U('huntingCargoLoadFailed'),
                4000
            )
            applyCargoStatus(status)
            isLoadingCarcass = false
            return
        end

        deleteLoadedCarcass(PlayerPedId(), carcass)
        applyCargoStatus(status)
        Core.NotifyRightTip(_U('huntingCargoLoaded', status.used, status.capacity), 4000)
        isLoadingCarcass = false
    end, request)
end

local function finalizeUnload(token, spawned, unloadedCarcass)
    Core.Callback.TriggerAsync('bcc-wagons:FinalizeHuntingCarcassUnload', function(success, status)
        applyCargoStatus(status)
        if not success then
            if entityExists(unloadedCarcass) then DeleteEntity(unloadedCarcass) end
            Core.NotifyRightTip(_U('huntingCargoUnloadFailed'), 4000)
            isLoadingCarcass = false
            return
        end

        Core.NotifyRightTip(
            _U('huntingCargoUnloaded', huntingCargoUsed, huntingCargoCapacity),
            4000
        )
        isLoadingCarcass = false
    end, { token = token, spawned = spawned })
end

local function unloadCarcass()
    if isLoadingCarcass then return end
    local request = huntingWagonRequest()
    if not request then return end
    isLoadingCarcass = true

    Core.Callback.TriggerAsync('bcc-wagons:ReserveHuntingCarcassUnload', function(success, reservation)
        if not success or type(reservation) ~= 'table' then
            Core.NotifyRightTip(_U('huntingCargoUnloadFailed'), 4000)
            isLoadingCarcass = false
            return
        end

        local modelHash = tonumber(reservation.modelHash)
        if not modelHash or not LoadModel(modelHash, tostring(modelHash)) then
            finalizeUnload(reservation.token, false)
            return
        end

        local settings = Config.huntingWagon or {}
        local rear = settings.rearOffset or {}
        local spawnCoords = GetOffsetFromEntityInWorldCoords(
            MyWagon,
            tonumber(rear.x) or 0.0,
            (tonumber(rear.y) or -2.25) - 0.75,
            (tonumber(rear.z) or 0.0) + 0.25
        )
        local carcass = CreatePed(
            modelHash,
            spawnCoords.x,
            spawnCoords.y,
            spawnCoords.z,
            GetEntityHeading(MyWagon),
            true,
            true
        )
        SetModelAsNoLongerNeeded(modelHash)

        if not entityExists(carcass) then
            finalizeUnload(reservation.token, false)
            return
        end

        local reservationIsSkinned = reservation.isSkinned == true
            or tonumber(reservation.isSkinned) == 1

        SetEntityAsMissionEntity(carcass, true, true)
        local outfitHash = tonumber(reservation.outfitHash) or 0
        if not reservationIsSkinned then
            Citizen.InvokeNative(0x283978A15512B2FE, carcass, true) -- SetRandomOutfitVariation
            Wait(0)
            if outfitHash ~= 0 and EquipMetaPedOutfit then
                EquipMetaPedOutfit(carcass, outfitHash)
                Citizen.InvokeNative(NATIVE_FIX_PED_OUTFIT, carcass, true)
                Citizen.InvokeNative(
                    NATIVE_UPDATE_PED_VARIATION,
                    carcass,
                    false,
                    true,
                    true,
                    true,
                    false
                )
            end
        end

        SetEntityVisible(carcass, true, false)
        ResetEntityAlpha(carcass)
        SetEntityHealth(carcass, 0, PlayerPedId())
        Citizen.InvokeNative(
            NATIVE_SET_PED_QUALITY,
            carcass,
            math.max(0, math.min(2, tonumber(reservation.quality) or 0))
        )
        if reservationIsSkinned then
            Wait(1000)
            Citizen.InvokeNative(NATIVE_SET_ENTITY_FULLY_LOOTED, carcass, true)
            applyCarcassMetaTags(carcass, reservation.metaTags)

            -- Preserve the logical state if this reconstructed entity is loaded
            -- into the wagon again before it is removed by the game.
            if NetworkGetEntityIsNetworked(carcass) then
                Entity(carcass).state:set('bccWagonSkinned', true, true)
            end
        end
        PlaceEntityOnGroundProperly(carcass, true)
        finalizeUnload(reservation.token, true, carcass)
    end, request)
end

CreateThread(function()
    createLoadPrompt()
    setHuntingPromptState(false, false)

    while true do
        local sleep = 750
        local loadPromptEnabled = false
        local unloadPromptEnabled = false
        if not isLoadingCarcass and IsActiveHuntingWagon() and GetEntitySpeed(MyWagon) < 0.5 then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local carcass = carriedDeadAnimal(playerPed)
            if carcass ~= 0 or huntingCargoUsed > 0 then
                local settings = Config.huntingWagon or {}
                local rear = settings.rearOffset or {}
                local rearCoords = GetOffsetFromEntityInWorldCoords(
                    MyWagon,
                    tonumber(rear.x) or 0.0,
                    tonumber(rear.y) or -2.25,
                    tonumber(rear.z) or 0.0
                )

                if #(playerCoords - rearCoords)
                    <= (tonumber(settings.interactionDistance) or 2.25) then
                    sleep = 0
                    Citizen.InvokeNative(
                        NATIVE_PROMPT_CONTEXT_SET_POINT,
                        HuntingLoadPrompt,
                        rearCoords.x,
                        rearCoords.y,
                        rearCoords.z
                    )
                    Citizen.InvokeNative(
                        NATIVE_PROMPT_CONTEXT_SET_POINT,
                        HuntingUnloadPrompt,
                        rearCoords.x,
                        rearCoords.y,
                        rearCoords.z
                    )
                    if carcass ~= 0 then
                        loadPromptEnabled = true
                        if Citizen.InvokeNative(NATIVE_PROMPT_HAS_HOLD_MODE_COMPLETED, HuntingLoadPrompt) then
                            loadCarcass(carcass)
                        end
                    else
                        unloadPromptEnabled = true
                        if Citizen.InvokeNative(NATIVE_PROMPT_HAS_HOLD_MODE_COMPLETED, HuntingUnloadPrompt) then
                            unloadCarcass()
                        end
                    end
                end
            end
        end
        setHuntingPromptState(loadPromptEnabled, unloadPromptEnabled)
        Wait(sleep)
    end
end)
