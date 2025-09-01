local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
---@type BCCWagonsDebugLib
local DBG = BCCWagonsDebug or {
    Info = function() end,
    Error = function() end,
    Warning = function() end,
    Success = function() end
}

local Discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.WebhookAvatar)

Core.Callback.Register('bcc-wagons:BuyWagon', function(source, cb, data)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local maxWagons = Config.maxPlayerWagons
    if data.isWainwright then
        maxWagons = Config.maxWainwrightWagons
    end
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    if #wagons >= maxWagons then
        Core.NotifyRightTip(src, _U('wagonLimit') .. maxWagons .. _U('wagons'), 4000)
        cb(false)
        return
    end
    if data.IsCash then
        if character.money >= data.Cash then
            cb(true)
        else
            Core.NotifyRightTip(src, _U('shortCash'), 4000)
            cb(false)
        end
    else
        if character.gold >= data.Gold then
            cb(true)
        else
            Core.NotifyRightTip(src, _U('shortGold'), 4000)
            cb(false)
        end
    end
end)

Core.Callback.Register('bcc-wagons:SaveNewWagon', function(source, cb, wagonInfo)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local identifier = character.identifier
    local charid = character.charIdentifier
    local model = wagonInfo.wagonData.ModelW
    local cash = wagonInfo.wagonData.IsCash
    local name = wagonInfo.name

    for _, wagonModels in pairs(Wagons) do
        for modelWagon, wagonConfig in pairs(wagonModels.types) do
            if model == modelWagon then
                local cashPrice = wagonConfig.cashPrice
                local goldPrice = wagonConfig.goldPrice

                if (cash) and (character.money >= cashPrice) then
                    character.removeCurrency(0, cashPrice)
                    Discord:sendMessage("Name: " .. character.firstname .. " " .. character.lastname .. "\nIdentifier: " .. character.identifier
                    .. "\nWagon Name: " .. name .. "\nWagon Model: " .. model .. "\nFor cash: $" .. cashPrice)

                elseif (not cash) and (character.gold >= goldPrice) then
                    character.removeCurrency(1, goldPrice)
                    Discord:sendMessage("Name: " .. character.firstname .. " " .. character.lastname .. "\nIdentifier: " .. character.identifier
                    .. "\nWagon Name: " .. name .. "\nWagon Model: " .. model .. "\nFor Gold: " .. goldPrice)

                else
                    if cash then
                        Core.NotifyRightTip(src, _U('shortCash'), 4000)
                    else
                        Core.NotifyRightTip(src, _U('shortGold'), 4000)
                    end
                    return cb(true)
                end

                local condition = wagonConfig.condition.maxAmount
                MySQL.query.await('INSERT INTO `player_wagons` (`identifier`, `charid`, `name`, `model`, `condition`) VALUES (?, ?, ?, ?, ?)',
                    { identifier, charid, name, model, condition })
                break
            end
        end
    end
    cb(true)
end)

Core.Callback.Register('bcc-wagons:UpdateWagonName', function(source, cb, wagonInfo)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    MySQL.query.await('UPDATE `player_wagons` SET `name` = ? WHERE `charid` = ? AND `id` = ?', { wagonInfo.name, charid, wagonInfo.wagonData.WagonId })
    cb(true)
end)

RegisterNetEvent('bcc-wagons:SelectWagon', function(data)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local id = tonumber(data.WagonId)

    local wagon = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    for i = 1, #wagon do
        MySQL.query.await('UPDATE `player_wagons` SET `selected` = ? WHERE `charid` = ? AND `id` = ?', { 0, charid, wagon[i].id })
        if wagon[i].id == id then
            MySQL.query.await('UPDATE `player_wagons` SET `selected` = ? WHERE `charid` = ? AND `id` = ?', { 1, charid, id })
        end
    end
end)

Core.Callback.Register('bcc-wagons:GetWagonData', function(source, cb)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local data = nil

    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    if #wagons ~= 0 then
        for i = 1, #wagons do
            if wagons[i].selected == 1 then
                TriggerClientEvent('bcc-wagons:SpawnWagon', src, wagons[i].model, wagons[i].name, wagons[i].id)
                data = {
                    model = wagons[i].model,
                    name = wagons[i].name,
                    id = wagons[i].id
                }
                cb(data)
            end
        end
        if data == nil then
            Core.NotifyRightTip(src, _U('noSelectedWagon'), 4000)
            cb(false)
        end
    else
        Core.NotifyRightTip(src, _U('noOwnedWagons'), 4000)
        cb(false)
    end
end)

Core.Callback.Register('bcc-wagons:GetMyWagons', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        --DebugPrint('User not found for source: ' .. tostring(src))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local identifier = character.identifier
    local charid = character.charIdentifier

    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ? AND `identifier` = ?', { charid, identifier })

    cb(wagons)
end)

Core.Callback.Register('bcc-wagons:SellMyWagon', function(source, cb, data)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local modelWagon = nil
    local id = tonumber(data.WagonId)

    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    for i = 1, #wagons do
        if tonumber(wagons[i].id) == id then
            modelWagon = wagons[i].model
            MySQL.query.await('DELETE FROM `player_wagons` WHERE `charid` = ? AND `id` = ?', { charid, id })
        end
    end
    for _, wagonModels in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonModels.types) do
            if model == modelWagon then
                local sellPrice = (Config.sellPrice * wagonConfig.cashPrice)
                sellPrice = math.floor(sellPrice)  -- Round to the nearest whole number
                character.addCurrency(0, sellPrice)
                Discord:sendMessage("Name: " .. character.firstname .. " " .. character.lastname .. "\nIdentifier: " .. character.identifier .. "\nWagon Name: " .. data.WagonName .. "\nWagon Model: " .. data.WagonModel .. "\nSold for: $" .. sellPrice)
                Core.NotifyRightTip(src, _U('soldWagon') .. data.WagonName .. _U('frcash') .. sellPrice, 4000)
                cb(true)
                return  -- Ensure callback is called once
            end
        end
    end
    cb(false)  -- Call callback with false if wagon not found or not sold
end)

Core.Callback.Register('bcc-wagons:SaveWagonTrade', function(source, cb, serverId, wagonId)
    -- Current Owner
    local src = source
    local curUser = Core.getUser(src)
    if not curUser then return cb(false) end
    local curOwner = curUser.getUsedCharacter
    local curOwnerName = curOwner.firstname .. " " .. curOwner.lastname
    -- New Owner
    local newUser = Core.getUser(serverId)
    if not newUser then return cb(false) end
    local newOwner = newUser.getUsedCharacter
    local newOwnerId = newOwner.identifier
    local newOwnerCharId = newOwner.charIdentifier
    local newOwnerName = newOwner.firstname .. " " .. newOwner.lastname
    local charJob = newOwner.job
    local jobGrade = newOwner.jobGrade

    local isWainwright = false
    isWainwright = CheckPlayerJob(charJob, jobGrade, Config.wainwrightJob)
    local maxWagons = Config.maxPlayerWagons
    if isWainwright then
        maxWagons = Config.maxWainwrightWagons
    end
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { newOwnerCharId })
    if #wagons >= maxWagons then
        Core.NotifyRightTip(src, _U('tradeFailed') .. newOwnerName .. _U('tooManyWagons'), 5000)
        cb(false)
        return
    end

    MySQL.query.await('UPDATE `player_wagons` SET `identifier` = ?, `charid` = ?, `selected` = ? WHERE `id` = ?', { newOwnerId, newOwnerCharId, 0, wagonId })
    Discord:sendMessage("Current Owner: " .. curOwnerName .. "\nIdentifier: " .. curOwner.identifier .. "\nGave a wagon to: " .. "\nNew Owner: " .. newOwnerName .. "\nIdentifier: " .. newOwnerId)
    Core.NotifyRightTip(src, _U('youGave') .. newOwnerName .. _U('aWagon'), 4000)
    Core.NotifyRightTip(serverId, curOwnerName .._U('gaveWagon'), 4000)
    cb(true)
end)

RegisterNetEvent('bcc-wagons:RegisterInventory', function(id, wagonModel)
    local idStr = 'wagon_' .. tostring(id)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(idStr)

    for _, wagonModels in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonModels.types) do
            if model == wagonModel then
                local data = {
                    id = idStr,
                    name = _U('wagonInv'),
                    limit = tonumber(wagonConfig.inventory.limit),
                    acceptWeapons = wagonConfig.inventory.weapons,
                    shared = wagonConfig.inventory.shared,
                    ignoreItemStackLimit = wagonConfig.inventory.ignoreItemStackLimit or true,
                    whitelistItems = wagonConfig.inventory.useWhiteList or false,
                    UsePermissions = wagonConfig.inventory.usePermissions or false,
                    UseBlackList = wagonConfig.inventory.useBlackList or false,
                    whitelistWeapons = wagonConfig.inventory.whitelistWeapons or false,
                }

                if isRegistered then
                    exports.vorp_inventory:updateCustomInventoryData(idStr, data)
                else
                    exports.vorp_inventory:registerInventory(data)
                end

                if data.UsePermissions then
                    for _, permission in ipairs(wagonConfig.inventory.permissions.allowedJobsTakeFrom) do
                        exports.vorp_inventory:AddPermissionTakeFromCustom(idStr, permission.name, permission.grade)
                    end
                    for _, permission in ipairs(wagonConfig.inventory.permissions.allowedJobsMoveTo) do
                        exports.vorp_inventory:AddPermissionMoveToCustom(idStr, permission.name, permission.grade)
                    end
                end

                if data.whitelistItems then
                    for _, item in ipairs(wagonConfig.inventory.itemsLimitWhiteList) do
                        exports.vorp_inventory:setCustomInventoryItemLimit(idStr, item.name, item.limit)
                    end
                end

                if data.whitelistWeapons then
                    for _, weapon in ipairs(wagonConfig.inventory.weaponsLimitWhiteList) do
                        exports.vorp_inventory:setCustomInventoryWeaponLimit(idStr, weapon.name, weapon.limit)
                    end
                end

                if data.UseBlackList then
                    for _, item in ipairs(wagonConfig.inventory.itemsBlackList) do
                        exports.vorp_inventory:BlackListCustomAny(idStr, item)
                    end
                end
                break
            end
        end
    end
end)

RegisterNetEvent('bcc-wagons:OpenInventory', function(id)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    exports.vorp_inventory:openInventory(src, 'wagon_' .. tostring(id))
end)

Core.Callback.Register('bcc-wagons:GetRepairLevel', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    local repairLevel = MySQL.query.await('SELECT `condition` FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?', { myWagonId, myWagonModel, charid })
    if repairLevel and repairLevel[1] then
        cb(repairLevel[1].condition)
    else
        cb(false)
    end
end)

Core.Callback.Register('bcc-wagons:UpdateRepairLevel', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    local wagonData = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?', { myWagonId, myWagonModel, charid })
    if not wagonData or not wagonData[1] then return cb(false) end

    local wagonCfg = nil
    for _, wagonModels in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonModels.types) do
            if myWagonModel == model then
                wagonCfg = wagonConfig
                break
            end
        end
    end

    if not wagonCfg then return cb(false) end

    local updateLevel = wagonData[1].condition - wagonCfg.condition.decreaseValue

    MySQL.query.await('UPDATE `player_wagons` SET `condition` = ? WHERE `id` = ? AND `charid` = ?', { updateLevel, myWagonId, charid })

    cb(updateLevel)
end)

Core.Callback.Register('bcc-wagons:GetItemDurability', function(source, cb, item)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end

    local tool = exports.vorp_inventory:getItem(src, item)
    if not tool then return cb('0') end

    local toolMeta = tool['metadata']
    cb(toolMeta.durability)
end)

local function UpdateRepairItem(src, item)
    local toolUsage = Config.repair.usage
    local tool = exports.vorp_inventory:getItem(src, item)
    local toolMeta = tool['metadata']
    local durabilityValue

    if next(toolMeta) == nil then
        durabilityValue = 100 - toolUsage
        exports.vorp_inventory:subItem(src, item, 1, {})
        exports.vorp_inventory:addItem(src, item, 1, { description = _U('durability') .. '<span style=color:yellow;>' .. tostring(durabilityValue) .. '%' .. '</span>', durability = durabilityValue })
    else
        durabilityValue = toolMeta.durability - toolUsage
        exports.vorp_inventory:subItem(src, item, 1, toolMeta)

        if durabilityValue >= toolUsage then
            exports.vorp_inventory:subItem(src, item, 1, toolMeta)
            exports.vorp_inventory:addItem(src, item, 1, { description = _U('durability') .. '<span style=color:yellow;>' .. tostring(durabilityValue) .. '%' .. '</span>', durability = durabilityValue })
        elseif durabilityValue < toolUsage then
            exports.vorp_inventory:subItem(src, item, 1, toolMeta)
            Core.NotifyRightTip(src, _U('needNewTool'), 4000)
        end
    end
end

Core.Callback.Register('bcc-wagons:RepairWagon', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local item = Config.repair.item

    local hasItem = exports.vorp_inventory:getItem(src, item)
    if not hasItem then
        Core.NotifyRightTip(src, _U('youNeed') .. Config.repair.label  .. _U('toRepair'), 4000)
        return cb(false)
    end

    local wagonData = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?', { myWagonId, myWagonModel, charid })
    if not wagonData or not wagonData[1] then return cb(false) end

    local wagonCfg = nil
    for _, wagonModels in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonModels.types) do
            if myWagonModel == model then
                wagonCfg = wagonConfig
                break
            end
        end
    end

    if not wagonCfg then return cb(false) end

    if wagonData[1].condition >= wagonCfg.condition.maxAmount then return cb(false) end

    local updateLevel = wagonData[1].condition + wagonCfg.condition.repairValue
    if updateLevel > wagonCfg.condition.maxAmount then
        updateLevel = wagonCfg.condition.maxAmount
    end

    MySQL.query.await('UPDATE `player_wagons` SET `condition` = ? WHERE `id` = ? AND `charid` = ?', { updateLevel, myWagonId, charid })

    UpdateRepairItem(src, item)

    cb(updateLevel)
end)

if Config.outfitsAtWagon then

    RegisterNetEvent('bcc-wagons:GetOutfits', function()
        local src = source
        local user = Core.getUser(src)
        if not user then return end
        local character = user.getUsedCharacter
        local identifier = character.identifier
        local charIdentifier = character.charIdentifier

        exports.oxmysql:execute("SELECT * FROM outfits WHERE `identifier` = ? AND `charidentifier` = ?", { identifier, charIdentifier }, function(result)
            if result[1] then
                TriggerClientEvent('bcc-wagons:LoadOutfits', src, { comps = character.comps, compTints = character.compTints }, result)
            end
        end)
    end)

    RegisterNetEvent('bcc-wagons:setOutfit', function(Outfit, CacheComps)
        local src = source
        local user = Core.getUser(src)
        if not user then return end
        local character = user.getUsedCharacter
            if CacheComps then
                user.updateComps(json.encode(CacheComps))
            end

            if Outfit then
                user.updateSkin(json.encode(Outfit))
            end
        --[[character.updateComps(Outfit.comps)
        character.updateCompTints(Outfit.compTints or '{}')
    
        TriggerClientEvent('vorpcharacter:updateCache', src, Outfit, CacheComps)]]--
    end)
end

Core.Callback.Register('bcc-wagons:CheckJob', function(source, cb, wainwright, site)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charJob = character.job
    local jobGrade = character.jobGrade
    if not charJob then
        cb(false)
        return
    end
    local jobConfig
    if wainwright then
        jobConfig = Config.wainwrightJob
    else
        jobConfig = Sites[site].shop.jobs
    end
    local hasJob = false
    hasJob = CheckPlayerJob(charJob, jobGrade, jobConfig)
    if hasJob then
        cb({ true, charJob })
    else
        cb({ false, charJob })
    end
end)

function CheckPlayerJob(charJob, jobGrade, jobConfig)
    for _, job in pairs(jobConfig) do
        if (charJob == job.name) and (tonumber(jobGrade) >= tonumber(job.grade)) then
            return true
        end
    end
end

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-wagons')
