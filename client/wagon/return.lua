local DISMOUNT_TIMEOUT_MS = 5000

local function wagonExists(wagon)
    return wagon and wagon ~= 0 and DoesEntityExist(wagon)
end

local function deleteWagonEntity(wagon)
    if not wagonExists(wagon) then return end

    SetEntityAsMissionEntity(wagon, true, true)
    DeleteEntity(wagon)
end

local function clearActiveWagon(wagon)
    -- Delayed cleanup must not clear a wagon that was spawned in the meantime.
    if MyWagon ~= wagon then return false end

    LocalPlayer.state.WagonData = { MyWagon = 0 }
    MyWagon = 0
    MyWagonId = nil
    WagonName = nil
    return true
end

-- Return wagon at a shop with prompt
---@param silent boolean|nil
function ReturnWagon(silent)
    local playerPed = PlayerPedId()
    local wagon = MyWagon

    if not wagonExists(wagon) then
        Core.NotifyRightTip(_U('noWagon'), 4000)
        return
    end

    -- Ask the player to leave the wagon before deleting it.
    if Citizen.InvokeNative(0xA808AA1D79230FC2, playerPed, wagon) then -- IsPedSittingInVehicle
        Citizen.InvokeNative(0xD3DBCE61A490BE02, playerPed, wagon, 0, 0) -- TaskLeaveVehicle
        local dismountDeadline = GetGameTimer() + DISMOUNT_TIMEOUT_MS

        while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) -- IsPedOnFoot
            and GetGameTimer() < dismountDeadline do
            Wait(10)
        end
    end

    GetControlOfWagon()
    TriggerEvent('bcc-wagons:client:wagonReturning', {
        entity = wagon,
        id = MyWagonId,
        model = MyWagonModel,
    })
    deleteWagonEntity(wagon)
    clearActiveWagon(wagon)

    if not silent then Core.NotifyRightTip(_U('wagonReturned'), 4000) end
end
