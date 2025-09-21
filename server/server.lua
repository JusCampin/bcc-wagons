local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local Discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.WebhookAvatar)
---@type BCCWagonsDebugLib
local DBG = BCCWagonsDebug

local function CheckPlayerJob(charJob, jobGrade, jobConfig)
    -- Nil checks
    if not charJob or not jobGrade or not jobConfig then
        DBG.Warning('Job check failed due to nil values in parameters')
        return false
    end

    -- Validate jobGrade is a number
    if type(jobGrade) ~= 'number' then
        DBG.Warning('Job check failed: jobGrade is not a number')
        return false
    end

    -- Check for empty config
    if #jobConfig == 0 then
        DBG.Warning('Job check failed: jobConfig is empty')
        return false
    end

    -- Iterate through job config
    for _, job in ipairs(jobConfig) do
        if charJob:lower() == job.name:lower() and jobGrade >= job.grade then
            DBG.Success(('Job check passed: %s (grade %d) >= %s (grade %d)'):format(charJob, jobGrade, job.name, job.grade))
            return true
        end
        DBG.Warning(('Job check failed: %s (grade %d) vs %s (grade %d)'):format(charJob, jobGrade, job.name, job.grade))
    end

    return false
end

Core.Callback.Register('bcc-wagons:CheckJob', function(source, cb, wainwright, site)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charJob = character.job
    local jobGrade = character.jobGrade

    -- Determine the job config based on input
    local jobConfig
    if site and Sites[site] and Sites[site].shop and Sites[site].shop.jobs then
        jobConfig = Sites[site].shop.jobs
    elseif wainwright and Config.wainwrightJob then
        jobConfig = Config.wainwrightJob
    else
        DBG.Warning('No valid job config found for site or wainwright.')
        return cb(false)
    end

    -- Check if the player meets the job requirements
    if not CheckPlayerJob(charJob, jobGrade, jobConfig) then
        DBG.Warning(('Player %s (job: %s, grade: %d) does not meet job requirements.'):format(
            tostring(character.identifier),
            tostring(charJob),
            tonumber(jobGrade)
        ))
        return cb(false)
    end

    DBG.Success(('User %s has the required job (%s) and grade (%d).'):format(
        tostring(character.identifier),
        tostring(charJob),
        tonumber(jobGrade)
    ))
    cb(true)
end)

Core.Callback.Register('bcc-wagons:BuyWagon', function(source, cb, data)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local maxWagons = data.isWainwright and Config.maxWagons.wainwright or Config.maxWagons.player
    local model = data.Model

    -- Check wagon limit
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    if #wagons >= maxWagons then
        Core.NotifyRightTip(src, _U('wagonLimit') .. tostring(maxWagons) .. _U('wagons'), 4000)
        DBG.Warning(('Player %s reached wagon limit (%d)'):format(tostring(charid), maxWagons))
        return cb(false)
    end

    -- Find the wagon config
    local wagonConfig
    for _, wagonTypes in pairs(Wagons) do
        for modelWagon, config in pairs(wagonTypes.models) do
            if model == modelWagon then
                wagonConfig = config
                break
            end
        end
        if wagonConfig then break end
    end

    if not wagonConfig then
        DBG.Error(('Invalid wagon model for BuyWagon: %s'):format(tostring(model)))
        return cb(false)
    end

    -- Check currency
    local currencyType = data.IsCash and 'money' or 'gold'
    local price = data.IsCash and wagonConfig.price.cash or wagonConfig.price.gold
    local currencyName = data.IsCash and 'cash' or 'gold'

    if not price then
        DBG.Error(('Invalid price for wagon model %s (currency: %s)'):format(tostring(model), currencyName))
        return cb(false)
    end

    if character[currencyType] < price then
        Core.NotifyRightTip(src, data.IsCash and _U('shortCash') or _U('shortGold'), 4000)
        DBG.Warning(('Player %s lacks %s (%d needed, %d available)'):format(
            tostring(charid), currencyName, price, character[currencyType]
        ))
        return cb(false)
    end

    -- Everything is valid, proceed to purchase
    DBG.Info(('Player %s can purchase wagon %s for %d %s'):format(
        tostring(charid), tostring(model), price, currencyName
    ))
    return cb(true)
end)

Core.Callback.Register('bcc-wagons:SaveNewWagon', function(source, cb, data, name)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local identifier = character.identifier
    local charid = character.charIdentifier
    local model = data.Model

    -- Find the wagon config
    local wagonConfig
    for _, wagonTypes in pairs(Wagons) do
        for wagonModel, config in pairs(wagonTypes.models) do
            if model == wagonModel then
                wagonConfig = config
                break
            end
        end
        if wagonConfig then break end
    end

    if not wagonConfig then
        DBG.Error(('Invalid wagon model for SaveNewWagon: %s'):format(tostring(model)))
        return cb(false)
    end

    -- Determine price and currency type
    local price, currencyName
    if data.IsCash then
        price = wagonConfig.price.cash
        currencyName = 'cash'
    else
        price = wagonConfig.price.gold
        currencyName = 'gold'
    end

    if not price then
        DBG.Error(('Invalid price for wagon model %s (currency: %s)'):format(tostring(model), currencyName))
        return cb(false)
    end

    -- Check currency again (just in case)
    if (data.IsCash and character.money < price) or (not data.IsCash and character.gold < price) then
        Core.NotifyRightTip(src, data.IsCash and _U('shortCash') or _U('shortGold'), 4000)
        DBG.Warning(('Player %s lacks %s (%d needed, %d available)'):format(
            tostring(identifier), currencyName, price, data.IsCash and character.money or character.gold
        ))
        return cb(false)
    end

    -- Deduct currency
    character.removeCurrency(data.IsCash and 0 or 1, price)
    DBG.Info(('Deducted %d %s from player %s for wagon %s'):format(
        price, currencyName, tostring(identifier), tostring(model)
    ))

    -- Save the wagon to the database
    local condition = wagonConfig.condition and wagonConfig.condition.maxAmount or 100
    MySQL.query.await(
        'INSERT INTO `player_wagons` (`identifier`, `charid`, `name`, `model`, `condition`) VALUES (?, ?, ?, ?, ?)',
        { identifier, charid, name, model, condition }
    )
    DBG.Info(('Wagon saved: %s (ID: %s, CharID: %s, Name: %s)'):format(
        tostring(model), tostring(identifier), tostring(charid), tostring(name)
    ))

    -- Send Discord notification
    Discord:sendMessage(string.format(
        "Name: %s %s\nIdentifier: %s\nWagon Name: %s\nWagon Model: %s\nFor %s: %d",
        character.firstname or 'Unknown',
        character.lastname or '',
        identifier or 'Unknown',
        name or 'Unknown',
        model or 'Unknown',
        currencyName,
        price
    ))

    -- Success
    return cb(true)
end)

Core.Callback.Register('bcc-wagons:UpdateWagonName', function(source, cb, data, name)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local identifier = character.identifier
    local charid = character.charIdentifier
    local wagonId = tonumber(data.wagonId)

    if not wagonId then
        DBG.Error(('Invalid wagon ID for UpdateWagonName: %s'):format(tostring(data.wagonId)))
        return cb(false)
    end

    -- Check if the wagon exists and belongs to the player
    local wagon = MySQL.query.await('SELECT 1 FROM `player_wagons` WHERE `charid` = ? AND `identifier` = ? AND `id` = ?',
        { charid, identifier, wagonId }
    )

    if not wagon or #wagon == 0 then
        DBG.Error(('Wagon not found or does not belong to player: ID %d, CharID %s, Identifier %s'):format(
            wagonId, tostring(charid), tostring(identifier)
        ))
        return cb(false)
    end

    -- Update the wagon name
    MySQL.query.await('UPDATE `player_wagons` SET `name` = ? WHERE `charid` = ? AND `identifier` = ? AND `id` = ?',
        { name, charid, identifier, wagonId }
    )

    DBG.Info(('Updated wagon name: ID %d, CharID %s, New Name: %s'):format(
        wagonId, tostring(charid), tostring(name)
    ))

    cb(true)
end)

RegisterNetEvent('bcc-wagons:SelectWagon', function(data)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local id = data.wagonId

    DBG.Info(('Selecting wagon ID: %s for character ID: %s'):format(id, charid))

    -- Check if the wagon exists and belongs to the character
    local wagon = MySQL.query.await('SELECT 1 FROM `player_wagons` WHERE `charid` = ? AND `id` = ?', { charid, id })
    if #wagon == 0 then
        DBG.Error(('Wagon not found or does not belong to character. Wagon ID: %s, Char ID: %s'):format(id, charid))
        return
    end

    -- Deselect all wagons for the character
    local deselected = MySQL.update.await('UPDATE `player_wagons` SET `selected` = 0 WHERE `charid` = ?', { charid })
    -- Select the chosen wagon
    local selected = MySQL.update.await('UPDATE `player_wagons` SET `selected` = 1 WHERE `charid` = ? AND `id` = ?', { charid, id })

    -- Log success
    if deselected ~= nil and selected ~= nil then
        DBG.Success(('Updated wagon selection. Deselected: %d, Selected: %d'):format(deselected, selected))
    else
        DBG.Error('Failed to update wagon selection in database.')
    end
end)

Core.Callback.Register('bcc-wagons:GetWagonData', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    -- Fetch player's wagons
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    if not wagons or #wagons == 0 then
        Core.NotifyRightTip(src, _U('noOwnedWagons'), 4000)
        DBG.Warning(('Player %s has no owned wagons'):format(tostring(charid)))
        return cb(false)
    end

    -- Find the selected wagon
    local selectedWagon
    for i = 1, #wagons do
        if wagons[i].selected == 1 then
            selectedWagon = wagons[i]
            break
        end
    end

    if not selectedWagon then
        Core.NotifyRightTip(src, _U('noSelectedWagon'), 4000)
        DBG.Warning(('Player %s has no selected wagon'):format(tostring(charid)))
        return cb(false)
    end

    -- Trigger client event to spawn the wagon
    TriggerClientEvent('bcc-wagons:SpawnWagon', src, selectedWagon.model, selectedWagon.name, selectedWagon.id)

    -- Return wagon data
    local data = {
        model = selectedWagon.model,
        name = selectedWagon.name,
        id = selectedWagon.id
    }

    DBG.Info(('Retrieved selected wagon for player %s: ID %d, Model %s, Name %s'):format(
        tostring(charid), selectedWagon.id, selectedWagon.model, selectedWagon.name
    ))

    cb(data)
end)

Core.Callback.Register('bcc-wagons:GetMyWagons', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local identifier = character.identifier
    local charid = character.charIdentifier
    local charJob = character.job

    -- Fetch player's wagons
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ? AND `identifier` = ?', { charid, identifier })

    if not wagons then
        DBG.Error(('Failed to fetch wagons for player: %s'):format(tostring(identifier)))
        return cb({false, charJob})
    end

    DBG.Info(('Fetched %d wagons for player: %s'):format(#wagons, tostring(identifier)))
    cb({wagons, charJob})
end)

Core.Callback.Register('bcc-wagons:SellMyWagon', function(source, cb, data)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local id = data.wagonId
    local modelWagon = nil

    -- Fetch wagons for the character
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { charid })
    if not wagons or #wagons == 0 then
        DBG.Error(('No wagons found for character ID: %s'):format(tostring(charid)))
        return cb(false)
    end

    -- Find the wagon
    for i = 1, #wagons do
        if wagons[i].id == id then
            modelWagon = wagons[i].model
            break
        end
    end

    if not modelWagon then
        DBG.Error(('Wagon ID %d not found for character ID %s'):format(id, tostring(charid)))
        return cb(false)
    end

    -- Find the wagon config and calculate sell price
    local sellPrice = 0
    for _, wagonTypes in pairs(Wagons) do
        for model, wagonConfig in pairs(wagonTypes.models) do
            if model == modelWagon then
                if not wagonConfig.price or not wagonConfig.price.cash then
                    DBG.Error(('Invalid wagon config for model %s (missing price)'):format(tostring(modelWagon)))
                    return cb(false)
                end
                sellPrice = math.floor(Config.sellPrice * wagonConfig.price.cash)
                break
            end
        end
    end

    if sellPrice <= 0 then
        DBG.Error(('Invalid sell price for wagon model %s'):format(tostring(modelWagon)))
        return cb(false)
    end

    -- Add currency to the character
    character.addCurrency(0, sellPrice)

    -- Delete the wagon
    MySQL.query.await('DELETE FROM `player_wagons` WHERE `charid` = ? AND `id` = ?', { charid, id })
    DBG.Info(('Deleted wagon ID %d for character ID %s after successful sale'):format(id, tostring(charid)))

    -- Send Discord notification
    Discord:sendMessage(string.format(
        "Name: %s %s\nIdentifier: %s\nWagon Name: %s\nWagon Model: %s\nSold for: $%d",
        character.firstname or 'Unknown',
        character.lastname or '',
        character.identifier or 'Unknown',
        data.wagonName or 'Unknown',
        data.wagonModel or 'Unknown',
        sellPrice
    ))

    -- Notify player
    Core.NotifyRightTip(src, _U('soldWagon') .. data.wagonName .. _U('frcash') .. tostring(sellPrice), 4000)
    DBG.Info(('Wagon sold: ID %d, Model %s, Price $%d'):format(id, modelWagon, sellPrice))
    return cb(true)
end)

Core.Callback.Register('bcc-wagons:SaveWagonTrade', function(source, cb, serverId, wagonId)
    -- Current Owner
    local src = source
    local curUser = Core.getUser(src)
    -- Check if the user exists
    if not curUser then
        DBG.Error(('Current user not found for source: %s'):format(tostring(src)))
        return cb(false)
    end
    local curOwner = curUser.getUsedCharacter
    local curOwnerName = ('%s %s'):format(curOwner.firstname, curOwner.lastname)

    -- New Owner
    local newUser = Core.getUser(serverId)
    -- Check if the user exists
    if not newUser then
        DBG.Error(('New user not found for server ID: %s'):format(tostring(serverId)))
        return cb(false)
    end
    local newOwner = newUser.getUsedCharacter
    local newOwnerId = newOwner.identifier
    local newOwnerCharId = newOwner.charIdentifier
    local newOwnerName = ('%s %s'):format(newOwner.firstname, newOwner.lastname)
    local charJob = newOwner.job
    local jobGrade = newOwner.jobGrade

    -- Check if new owner is a wainwright
    local isWainwright = CheckPlayerJob(charJob, jobGrade, Config.wainwrightJob)
    local maxWagons = isWainwright and Config.maxWagons.wainwright or Config.maxWagons.player

    -- Check if new owner has reached wagon limit
    local wagons = MySQL.query.await('SELECT * FROM `player_wagons` WHERE `charid` = ?', { newOwnerCharId })
    if #wagons >= maxWagons then
        Core.NotifyRightTip(src, _U('tradeFailed') .. newOwnerName .. _U('tooManyWagons'), 5000)
        DBG.Warning(('Trade failed: New owner %s has reached wagon limit (%d)'):format(newOwnerName, maxWagons))
        return cb(false)
    end

    -- Check if the wagon exists and belongs to the current owner
    local wagon = MySQL.query.await('SELECT 1 FROM `player_wagons` WHERE `id` = ? AND `charid` = ?', { wagonId, curOwner.charIdentifier })
    if not wagon or #wagon == 0 then
        DBG.Error(('Wagon not found or does not belong to current owner: ID %d, CharID %s'):format(wagonId, tostring(curOwner.charIdentifier)))
        return cb(false)
    end

    -- Transfer the wagon to the new owner
    MySQL.query.await('UPDATE `player_wagons` SET `identifier` = ?, `charid` = ?, `selected` = ? WHERE `id` = ?',
        { newOwnerId, newOwnerCharId, 0, wagonId }
    )
    -- Send Discord notification
    Discord:sendMessage(string.format(
        "Current Owner: %s\nIdentifier: %s\nGave a wagon to:\nNew Owner: %s\nIdentifier: %s",
        curOwnerName, curOwner.identifier, newOwnerName, newOwnerId
    ))

    -- Notify players
    Core.NotifyRightTip(src, (_U('youGave') or '') .. newOwnerName .. (_U('aWagon') or ''), 4000)
    Core.NotifyRightTip(serverId, curOwnerName .. (_U('gaveWagon') or ''), 4000)

    DBG.Info(('Wagon trade successful: ID %d from %s to %s'):format(wagonId, curOwnerName, newOwnerName))
    cb(true)
end)

RegisterNetEvent('bcc-wagons:RegisterInventory', function(id, wagonModel)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return
    end

    local idStr = 'wagon_' .. tostring(id)
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(idStr)

    -- Find the wagon config
    local wagonConfig
    for _, wagonTypes in pairs(Wagons) do
        for model, config in pairs(wagonTypes.models) do
            if model == wagonModel then
                wagonConfig = config
                break
            end
        end
        if wagonConfig then break end
    end

    if not wagonConfig then
        DBG.Error(('Invalid wagon model for RegisterInventory: %s'):format(tostring(wagonModel)))
        return
    end

    -- Prepare inventory data
    local data = {
        id = idStr,
        name = _U('wagonInv') or 'Wagon Inventory',
        limit = tonumber(wagonConfig.inventory.limit) or 50,
        acceptWeapons = wagonConfig.inventory.weapons or false,
        shared = wagonConfig.inventory.shared or false,
        ignoreItemStackLimit = wagonConfig.inventory.ignoreItemStackLimit or true,
        whitelistItems = wagonConfig.inventory.useWhiteList or false,
        UsePermissions = wagonConfig.inventory.usePermissions or false,
        UseBlackList = wagonConfig.inventory.useBlackList or false,
        whitelistWeapons = wagonConfig.inventory.whitelistWeapons or false,
    }

    -- Register or update the inventory
    if isRegistered then
        exports.vorp_inventory:updateCustomInventoryData(idStr, data)
        DBG.Info(('Updated inventory for wagon: %s'):format(idStr))
    else
        exports.vorp_inventory:registerInventory(data)
        DBG.Info(('Registered inventory for wagon: %s'):format(idStr))
    end

    -- Set up permissions
    if data.UsePermissions then
        for _, permission in ipairs(wagonConfig.inventory.permissions.allowedJobsTakeFrom) do
            exports.vorp_inventory:AddPermissionTakeFromCustom(idStr, permission.name, permission.grade)
        end
        for _, permission in ipairs(wagonConfig.inventory.permissions.allowedJobsMoveTo) do
            exports.vorp_inventory:AddPermissionMoveToCustom(idStr, permission.name, permission.grade)
        end
    end

    -- Set up item whitelist limits
    if data.whitelistItems then
        for _, item in ipairs(wagonConfig.inventory.itemsLimitWhiteList) do
            exports.vorp_inventory:setCustomInventoryItemLimit(idStr, item.name, item.limit)
        end
    end

    -- Set up weapon whitelist limits
    if data.whitelistWeapons then
        for _, weapon in ipairs(wagonConfig.inventory.weaponsLimitWhiteList) do
            exports.vorp_inventory:setCustomInventoryWeaponLimit(idStr, weapon.name, weapon.limit)
        end
    end

    -- Set up blacklist
    if data.UseBlackList then
        for _, item in ipairs(wagonConfig.inventory.itemsBlackList) do
            exports.vorp_inventory:BlackListCustomAny(idStr, item)
        end
    end
end)

RegisterNetEvent('bcc-wagons:OpenInventory', function(id)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return
    end

    -- Validate the wagon ID
    if not id then
        DBG.Error(('Invalid wagon ID provided by source: %s'):format(tostring(src)))
        return
    end

    -- Open the wagon inventory
    local inventoryId = 'wagon_' .. tostring(id)
    exports.vorp_inventory:openInventory(src, inventoryId)

    DBG.Info(('Player %s opened wagon inventory: %s'):format(tostring(src), inventoryId))
end)

Core.Callback.Register('bcc-wagons:GetRepairLevel', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    -- Validate inputs
    if not myWagonId or not myWagonModel then
        DBG.Error(('Invalid wagon ID or model for source: %s'):format(tostring(src)))
        return cb(false)
    end

    -- Fetch wagon condition
    local repairLevel = MySQL.query.await(
        'SELECT `condition` FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?',
        { myWagonId, myWagonModel, charid }
    )

    if not repairLevel or not repairLevel[1] then
        DBG.Warning(('Wagon not found or does not belong to player: ID %s, Model %s, CharID %s'):format(
            tostring(myWagonId), tostring(myWagonModel), tostring(charid)
        ))
        return cb(false)
    end

    DBG.Info(('Fetched repair level for wagon: ID %s, Model %s, Condition %d'):format(
        tostring(myWagonId), tostring(myWagonModel), repairLevel[1].condition
    ))

    cb(repairLevel[1].condition)
end)

Core.Callback.Register('bcc-wagons:UpdateRepairLevel', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    -- Validate inputs
    if not myWagonId or not myWagonModel then
        DBG.Error(('Invalid wagon ID or model for source: %s'):format(tostring(src)))
        return cb(false)
    end

    -- Fetch wagon data
    local wagonData = MySQL.query.await(
        'SELECT * FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?',
        { myWagonId, myWagonModel, charid }
    )

    if not wagonData or not wagonData[1] then
        DBG.Warning(('Wagon not found or does not belong to player: ID %s, Model %s, CharID %s'):format(
            tostring(myWagonId), tostring(myWagonModel), tostring(charid)
        ))
        return cb(false)
    end

    -- Find wagon config
    local wagonConfig
    for _, wagonTypes in pairs(Wagons) do
        for model, config in pairs(wagonTypes.models) do
            if myWagonModel == model then
                wagonConfig = config
                break
            end
        end
        if wagonConfig then break end
    end

    if not wagonConfig then
        DBG.Error(('Wagon config not found for model: %s'):format(tostring(myWagonModel)))
        return cb(false)
    end

    -- Validate condition decrease value
    if not wagonConfig.condition or not wagonConfig.condition.decreaseValue then
        DBG.Error(('Invalid condition decrease value for wagon model: %s'):format(tostring(myWagonModel)))
        return cb(false)
    end

    -- Calculate new condition level
    local currentCondition = wagonData[1].condition
    local decreaseValue = wagonConfig.condition.decreaseValue
    local updateLevel = math.max(0, currentCondition - decreaseValue)

    -- Update wagon condition
    MySQL.query.await(
        'UPDATE `player_wagons` SET `condition` = ? WHERE `id` = ? AND `charid` = ?',
        { updateLevel, myWagonId, charid }
    )

    DBG.Info(('Updated repair level for wagon: ID %s, Model %s, New Condition %d'):format(
        tostring(myWagonId), tostring(myWagonModel), updateLevel
    ))

    cb(updateLevel)
end)

Core.Callback.Register('bcc-wagons:GetItemDurability', function(source, cb, item)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    -- Validate item input
    if not item then
        DBG.Error(('Invalid item provided by source: %s'):format(tostring(src)))
        return cb(false)
    end

    -- Fetch item from inventory
    local tool = exports.vorp_inventory:getItem(src, item)
    if not tool then
        DBG.Warning(('Item not found in inventory for source: %s, Item: %s'):format(tostring(src), tostring(item)))
        return cb('0')  -- Return '0' as fallback for missing items
    end

    -- Extract durability from metadata
    local toolMeta = tool.metadata
    if not toolMeta or toolMeta.durability == nil then
        DBG.Warning(('Item metadata or durability missing for source: %s, Item: %s'):format(tostring(src), tostring(item)))
        return cb('0')  -- Return '0' as fallback for missing durability
    end

    DBG.Info(('Fetched durability for item: %s, Durability: %s'):format(tostring(item), tostring(toolMeta.durability)))
    cb(toolMeta.durability)
end)

local function UpdateRepairItem(src, item)
    local toolUsage = Config.repair.usage
    if not toolUsage or toolUsage <= 0 then
        DBG.Error('Invalid repair tool usage value in config')
        return
    end

    -- Check if the tool exists in the player's inventory
    local tool = exports.vorp_inventory:getItem(src, item)
    if not tool then
        DBG.Error(('Tool not found in inventory for source: %s, Item: %s'):format(tostring(src), tostring(item)))
        return
    end

    local toolMeta = tool.metadata or {}
    local durabilityValue

    -- If tool has no durability metadata, initialize it
    if not toolMeta.durability then
        durabilityValue = 100 - toolUsage
        exports.vorp_inventory:setItemMetadata(src, tool.id, {
            description = _U('durability') .. durabilityValue .. '%',
            durability = durabilityValue
        })
        DBG.Info(('Initialized durability for tool: %s, Durability: %d'):format(item, durabilityValue))
    else
        -- Subtract durability
        durabilityValue = toolMeta.durability - toolUsage

        -- Update the tool's metadata
        if durabilityValue >= toolUsage then
            exports.vorp_inventory:setItemMetadata(src, tool.id, {
                description = _U('durability') .. durabilityValue .. '%',
                durability = durabilityValue
            })
            DBG.Info(('Updated tool durability for source: %s, Tool: %s, Durability: %d'):format(tostring(src), item, durabilityValue))
        else
            -- Remove the tool if durability is exhausted
            exports.vorp_inventory:subItemById(src, tool.id, nil, nil, 1)
            Core.NotifyRightTip(src, _U('needNewTool'), 4000)
            DBG.Info(('Removed broken tool for source: %s, Tool: %s'):format(tostring(src), item))
        end
    end
end

Core.Callback.Register('bcc-wagons:RepairWagon', function(source, cb, myWagonId, myWagonModel)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG.Error(('User not found for source: %s'):format(tostring(src)))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charid = character.charIdentifier
    local item = Config.repair.item
    local repairLabel = Config.repair.label

    -- Check if the player has the repair tool
    local hasItem = exports.vorp_inventory:getItem(src, item)
    if not hasItem then
        Core.NotifyRightTip(src, _U('youNeed') .. repairLabel .. _U('toRepair'), 4000)
        DBG.Warning(('Player %s does not have the repair tool: %s'):format(tostring(src), item))
        return cb(false)
    end

    -- Fetch wagon data
    local wagonData = MySQL.query.await(
        'SELECT * FROM `player_wagons` WHERE `id` = ? AND `model` = ? AND charid = ?',
        { myWagonId, myWagonModel, charid }
    )

    if not wagonData or not wagonData[1] then
        DBG.Error(('Wagon not found or does not belong to player: ID %s, Model %s, CharID %s'):format(
            tostring(myWagonId), tostring(myWagonModel), tostring(charid)
        ))
        return cb(false)
    end

    -- Find wagon config
    local wagonConfig
    for _, wagonTypes in pairs(Wagons) do
        for model, config in pairs(wagonTypes.models) do
            if myWagonModel == model then
                wagonConfig = config
                break
            end
        end
        if wagonConfig then break end
    end

    if not wagonConfig then
        DBG.Error(('Wagon config not found for model: %s'):format(tostring(myWagonModel)))
        return cb(false)
    end

    -- Check if wagon is already at max condition
    if wagonData[1].condition >= wagonConfig.condition.maxAmount then
        DBG.Warning(('Wagon is already at max condition: ID %s, Model %s'):format(tostring(myWagonId), tostring(myWagonModel)))
        return cb(false)
    end

    -- Calculate new condition level
    local repairValue = wagonConfig.condition.repairValue or 10
    local updateLevel = math.min(wagonData[1].condition + repairValue, wagonConfig.condition.maxAmount)

    -- Update wagon condition
    MySQL.update.await(
        'UPDATE `player_wagons` SET `condition` = ? WHERE `id` = ? AND `charid` = ?',
        { updateLevel, myWagonId, charid }
    )

    -- Update repair item durability
    UpdateRepairItem(src, item)

    DBG.Info(('Repaired wagon: ID %s, Model %s, New Condition %d'):format(
        tostring(myWagonId), tostring(myWagonModel), updateLevel
    ))

    cb(updateLevel)
end)

if Config.outfitsAtWagon then
    RegisterNetEvent('bcc-wagons:GetOutfits', function()
        local src = source
        local user = Core.getUser(src)

        -- Check if the user exists
        if not user then
            DBG.Error('User not found for source: ' .. tostring(src))
            return
        end

        local character = user.getUsedCharacter
        local identifier = character.identifier
        local charIdentifier = character.charIdentifier

        exports.oxmysql:execute("SELECT * FROM outfits WHERE `identifier` = ? AND `charidentifier` = ?",
            { identifier, charIdentifier }, function(result)
            if result[1] then
                TriggerClientEvent('bcc-wagons:LoadOutfits', src,
                    { comps = character.comps, compTints = character.compTints }, result)
            end
        end)
    end)

    RegisterNetEvent('bcc-wagons:setOutfit', function(Outfit, CacheComps)
        local src = source
        local user = Core.getUser(src)

        -- Check if the user exists
        if not user then
            DBG.Error('User not found for source: ' .. tostring(src))
            return
        end

        local character = user.getUsedCharacter
        if CacheComps then
            user.updateComps(json.encode(CacheComps))
        end

        if Outfit then
            user.updateSkin(json.encode(Outfit))
        end
        --[[character.updateComps(Outfit.comps)
        character.updateCompTints(Outfit.compTints or '{}')

        TriggerClientEvent('vorpcharacter:updateCache', src, Outfit, CacheComps)]] --
    end)
end

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-wagons')
