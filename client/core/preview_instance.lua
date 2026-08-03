local previewActive = false
local previewEntering = false
local previewRequestId = 0
local previewTransitionUntil = 0

function IsPreviewInstanceTransitioning()
    return previewEntering or previewActive or GetGameTimer() < previewTransitionUntil
end

function EnterPreviewInstance(callback)
    if previewActive then
        if callback then callback(true) end
        return
    end
    if previewEntering then return end

    previewEntering = true
    previewTransitionUntil = GetGameTimer() + 1500
    previewRequestId = previewRequestId + 1
    local requestId = previewRequestId

    Core.Callback.TriggerAsync('bcc-wagons:EnterPreviewInstance', function(success)
        if requestId ~= previewRequestId then
            TriggerServerEvent('bcc-wagons:ExitPreviewInstance')
            if callback then callback(false) end
            return
        end

        previewEntering = false
        previewActive = success == true
        previewTransitionUntil = 0
        if callback then callback(previewActive) end
    end)
end

function ExitPreviewInstance()
    local wasEntering = previewEntering
    previewRequestId = previewRequestId + 1
    previewEntering = false
    previewTransitionUntil = GetGameTimer() + 1000
    if not previewActive and not wasEntering then return end

    previewActive = false
    TriggerServerEvent('bcc-wagons:ExitPreviewInstance')
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then ExitPreviewInstance() end
end)
