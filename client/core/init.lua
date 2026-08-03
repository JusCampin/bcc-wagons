Core = exports.vorp_core:GetCore()
local bccUtils = exports['bcc-utils'].initiate()
FeatherMenu = exports['feather-menu'].initiate()
DBG = bccUtils.Debug:Get('bcc-wagons', Config.development.enabled)

if DBG then
    DBG:Enable()
    DBG:Info('Wagons debug initialized')
end

-- Initialize Globals
MyWagon, MyWagonId = 0, nil
InMenu = false
MyWagonName, MyWagonModel = nil, nil
MyEntity, ShopEntity = 0, 0
ShopPages = {}
ShopName = 'Wagon Shop'
ShopCam = nil
ExpandedWagonId = nil
SelectedModelKey = nil
