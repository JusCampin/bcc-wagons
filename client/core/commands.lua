RegisterCommand(Config.commands.wagonEnter, function()
    if MyWagon ~= 0 and DoesEntityExist(MyWagon) then
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
    ReturnWagon()
end, false)

-- Development helper for testing the Hunter Cart tarp native in-game.
RegisterCommand('wagonTarp', function(_, args)
    if not Config.development.enabled then return end

    local requestedHeight = tonumber(args[1])
    if not requestedHeight then
        Core.NotifyRightTip('Usage: /wagonTarp 0.0-1.0', 4000)
        return
    end

    local updated, tarpHeight = SetHuntingWagonTarpHeight(requestedHeight, false)
    if not updated then
        Core.NotifyRightTip('Spawn your Hunter Cart before testing the tarp.', 4000)
        return
    end

    Core.NotifyRightTip(('Hunting wagon tarp height: %.2f'):format(tarpHeight), 3000)
end, false)

RegisterCommand('wagonHuntingClear', function()
    if not Config.development.enabled then return end
    if not ClearHuntingCargoForTesting() then
        Core.NotifyRightTip('Spawn your Hunter Cart before clearing its hunting cargo.', 4000)
    end
end, false)
