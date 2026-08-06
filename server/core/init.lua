Core = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
DBG = BccUtils.Debug:Get('bcc-wagons', Config.development.enabled)

if DBG then
    DBG:Enable()
    DBG:Info('Wagons debug initialized')
end

-- Initiate Globals
InverseModelHashMap = {}

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-wagons')
