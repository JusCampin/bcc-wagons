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
