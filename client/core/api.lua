local function activeWagonData()
    local wagon = MyWagon
    if not wagon or wagon == 0 or not DoesEntityExist(wagon) then return nil end

    return {
        entity = wagon,
        netId = NetworkGetNetworkIdFromEntity(wagon),
        id = MyWagonId,
        model = MyWagonModel,
        type = MyWagonType,
        name = WagonName,
        active = IsMyWagonActive == true,
    }
end

local featureModels = {}

exports('RegisterWagonFeature', function(model, options)
    if type(model) ~= 'string' or model == '' or type(options) ~= 'table' then return false end
    model = model:lower()
    featureModels[model] = options

    if options.persistentWhenDistant == true then
        local autoReturn = Config.shop.autoReturn
        autoReturn.excludedModels = autoReturn.excludedModels or {}
        autoReturn.excludedModels[model] = true
    end
    return true
end)

exports('GetWagonFeature', function(model)
    return type(model) == 'string' and featureModels[model:lower()] or nil
end)

exports('GetActiveWagon', activeWagonData)

exports('IsActiveWagon', function(wagonId)
    local wagon = activeWagonData()
    return wagon ~= nil and (wagonId == nil or tonumber(wagon.id) == tonumber(wagonId))
end)

function EmitWagonLifecycleEvent(eventName)
    TriggerEvent(eventName, activeWagonData())
end
