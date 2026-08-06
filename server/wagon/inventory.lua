local WAGON_INVENTORY_PREFIX <const> = 'wagon_'
local DEFAULT_INVENTORY_LIMIT <const> = 100
local WAGONS_TABLE <const> = 'bcc_player_wagons'
local RegisteredInventories = {}

local function inventoryId(wagonId)
    return WAGON_INVENTORY_PREFIX .. wagonId
end

local function applyInventoryRules(id, data)
    if data.UsePermissions and Config.inventory.permissions then
        for _, permission in ipairs(Config.inventory.permissions.allowedJobsTakeFrom or {}) do
            exports.vorp_inventory:AddPermissionTakeFromCustom(id, permission.name, permission.grade)
        end

        for _, permission in ipairs(Config.inventory.permissions.allowedJobsMoveTo or {}) do
            exports.vorp_inventory:AddPermissionMoveToCustom(id, permission.name, permission.grade)
        end
    end

    if data.whitelistItems then
        for _, item in ipairs(Config.inventory.items.allowList or {}) do
            exports.vorp_inventory:setCustomInventoryItemLimit(id, item.name, item.limit)
        end
    end

    if data.whitelistWeapons then
        for _, weapon in ipairs(Config.inventory.weapons.allowList or {}) do
            exports.vorp_inventory:setCustomInventoryWeaponLimit(id, weapon.name, weapon.limit)
        end
    end

    if data.UseBlackList then
        for _, itemName in ipairs(Config.inventory.items.blockList or {}) do
            exports.vorp_inventory:BlackListCustomAny(id, itemName)
        end
    end
end

local function registerWagonInventory(wagonId, model)
    if RegisteredInventories[wagonId] then return true end

    local modelConfig = ServerUtils.getWagonConfig(model)
    if not modelConfig then
        DBG:Error(('Inventory registration failed for unknown wagon model: %s'):format(tostring(model)))
        return false
    end

    local id = inventoryId(wagonId)
    local data = {
        id = id,
        name = _U('wagonInv'),
        limit = tonumber(modelConfig.invLimit) or DEFAULT_INVENTORY_LIMIT,
        acceptWeapons = Config.inventory.weapons.enabled == true,
        shared = Config.inventory.shared == true,
        ignoreItemStackLimit = Config.inventory.items.ignoreStackLimit ~= false,
        whitelistItems = Config.inventory.items.useAllowList == true,
        UsePermissions = Config.inventory.permissions.enabled == true,
        UseBlackList = Config.inventory.items.useBlockList == true,
        whitelistWeapons = Config.inventory.weapons.useAllowList == true
    }

    exports.vorp_inventory:registerInventory(data)
    applyInventoryRules(id, data)
    RegisteredInventories[wagonId] = true
    return true
end

local function isWagonNearby(src, wagonId)
    local playerPed = GetPlayerPed(src)
    if playerPed == 0 then return false end

    local playerCoords = GetEntityCoords(playerPed)
    for _, vehicle in ipairs(GetAllVehicles()) do
        if tonumber(Entity(vehicle).state.myWagonId) == wagonId then
            local offset = playerCoords - GetEntityCoords(vehicle)
            return offset.x * offset.x + offset.y * offset.y + offset.z * offset.z <= 100.0
        end
    end

    return false
end

RegisterNetEvent('bcc-wagons:RegisterInventory', function(wagonId)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'wagon inventory registration')
    local targetWagonId = tonumber(wagonId)
    if not charId or not targetWagonId then return end

    MySQL.scalar(
        ('SELECT `model` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
        { targetWagonId, charId },
        function(model)
            if type(model) == 'string' then
                registerWagonInventory(targetWagonId, model)
            else
                DBG:Warning(('Rejected inventory registration for unowned wagon ID %s.'):format(targetWagonId))
            end
        end
    )
end)

RegisterNetEvent('bcc-wagons:OpenInventory', function(wagonId)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'wagon inventory open event')
    local targetWagonId = tonumber(wagonId)
    if not charId or not targetWagonId then return end

    MySQL.single(
        ('SELECT `model`, `charid` FROM `%s` WHERE `id` = ? LIMIT 1'):format(WAGONS_TABLE),
        { targetWagonId },
        function(row)
            if not row or type(row.model) ~= 'string' then return end

            local ownsWagon = tonumber(row.charid) == charId
            if not ownsWagon and (not Config.inventory.shared or not isWagonNearby(src, targetWagonId)) then
                return
            end

            if registerWagonInventory(targetWagonId, row.model) then
                exports.vorp_inventory:openInventory(src, inventoryId(targetWagonId))
            end
        end
    )
end)
