Core = exports.vorp_core:GetCore()
local bccUtils = exports['bcc-utils'].initiate()
FeatherMenu = exports['feather-menu'].initiate()
DBG = bccUtils.Debug:Get('bcc-wagons', Config.development.enabled)

if DBG then
    DBG:Enable()
    DBG:Info('Wagons debug initialized')
end

-- Initialize Globals
MyWagon, MyWagonId, MyEntityID = 0, nil, nil
WagonName = nil
InMenu = false
MyWagonType, MyWagonModel = nil, nil
ShopEntity, MyEntity  = 0, 0
ShopName, Site = _U('wagonShop'), nil
IsMyWagonActive = false
Cam = false
WagonCam = nil
ExpandedWagonId = nil
ShopPages = {}
SelectedModelKey = nil
IsRotating = false
RotateDirection = nil
IsSpawningWagonActive = false
ShopCam = nil

local inverseModelHashMap = {}

---@param modelHash number
---@return string|nil
function ResolveWagonModelName(modelHash)
    return inverseModelHashMap[modelHash]
end

Wagons.ModelJobLocks = {
    Models = {},
    Jobs = {}
}

-- Runs once on startup
CreateThread(function()
    if Wagons.JobLocks then
        for jobName, modelList in pairs(Wagons.JobLocks) do
            Wagons.ModelJobLocks.Jobs[jobName] = {}

            for _, modelKey in ipairs(modelList) do
                Wagons.ModelJobLocks.Jobs[jobName][modelKey] = true

                if not Wagons.ModelJobLocks.Models[modelKey] then
                    Wagons.ModelJobLocks.Models[modelKey] = {}
                end
                Wagons.ModelJobLocks.Models[modelKey][jobName] = true
            end
        end
    end
    DBG:Info("Job restriction lookup dictionaries successfully auto-compiled.")
end)

CreateThread(function()
    while not Wagons or not Wagons.ModelToTypeMap do Wait(500) end

    for modelName, _ in pairs(Wagons.ModelToTypeMap) do
        local rawHash = joaat(modelName)

        inverseModelHashMap[rawHash] = modelName

        if rawHash < 0 then
            inverseModelHashMap[rawHash + 4294967296] = modelName
        else
            inverseModelHashMap[rawHash - 4294967296] = modelName
        end
    end

    DBG:Info("Inverse Model Hash Map successfully auto-compiled.")
end)
