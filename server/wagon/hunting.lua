local CARGO_TABLE <const> = 'bcc_wagon_hunting_cargo'
local WAGONS_TABLE <const> = 'bcc_player_wagons'
local ActiveLoads = {}
local PendingUnloads = {}

local function encodeMetaTags(tags)
    if type(tags) ~= 'table' then return nil end
    local sanitized = {}
    for _, tag in pairs(tags) do
        if #sanitized >= 64 then break end
        if type(tag) == 'table' and tonumber(tag.drawable) then
            sanitized[#sanitized + 1] = {
                drawable = tonumber(tag.drawable) or 0,
                albedo = tonumber(tag.albedo) or 0,
                normal = tonumber(tag.normal) or 0,
                material = tonumber(tag.material) or 0,
                palette = tonumber(tag.palette) or 0,
                tint0 = tonumber(tag.tint0) or 0,
                tint1 = tonumber(tag.tint1) or 0,
                tint2 = tonumber(tag.tint2) or 0,
            }
        end
    end
    if #sanitized == 0 then return nil end
    return json.encode(sanitized)
end

local function decodeMetaTags(value)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return {} end
    local success, decoded = pcall(json.decode, value)
    return success and type(decoded) == 'table' and decoded or {}
end

local function huntingSettings()
    return Config.huntingWagon or {}
end

local function cargoCapacity()
    return math.max(1, math.floor(tonumber(huntingSettings().capacity) or 6))
end

local function cargoStatus(wagonId, callback)
    MySQL.scalar(
        ('SELECT COALESCE(SUM(`cargo_units`), 0) FROM `%s` WHERE `wagon_id` = ?'):format(CARGO_TABLE),
        { wagonId },
        function(used)
            callback(math.max(0, tonumber(used) or 0), cargoCapacity())
        end
    )
end

local function getAnimalSize(modelHash)
    local settings = huntingSettings()
    local fallback = math.max(1, math.floor(tonumber(settings.defaultAnimalSize) or 1))
    local size = exports['bcc-animal-data']:GetCargoUnits(modelHash, fallback)
    return math.max(1, math.floor(tonumber(size) or fallback))
end

local function validateOwnedHuntingWagonRecord(charId, data, callback)
    local wagonId = type(data) == 'table' and tonumber(data.wagonId)
    if not wagonId then return callback(false) end

    MySQL.scalar(
        ('SELECT `model` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
        { wagonId, charId },
        function(model)
            local settings = huntingSettings()
            callback(model == (settings.model or 'huntercart01'), wagonId)
        end
    )
end

local function validateOwnedHuntingWagon(src, charId, data, callback)
    validateOwnedHuntingWagonRecord(charId, data, function(valid, wagonId)
        if not valid then
            DBG:Warning(('Hunting cargo rejected: wagon %s is not a Hunter Cart.'):format(wagonId))
            return callback(false)
        end

        local playerPed = GetPlayerPed(src)
        if playerPed == 0 then return callback(false) end

        local playerCoords = GetEntityCoords(playerPed)
        local nearbyWagon
        for _, vehicle in ipairs(GetAllVehicles()) do
            if tonumber(Entity(vehicle).state.myWagonId) == wagonId
                and #(playerCoords - GetEntityCoords(vehicle)) <= 6.0 then
                nearbyWagon = vehicle
                break
            end
        end

        if not nearbyWagon then
            DBG:Warning(('Hunting cargo rejected: owned wagon %s was not synchronized nearby.'):format(wagonId))
            return callback(false)
        end

        callback(true, wagonId)
    end)
end

Core.Callback.Register('bcc-wagons:GetHuntingCargoStatus', function(source, cb, data)
    local _, charId = ServerUtils.getCharacter(source, 'hunting cargo status')
    if not charId then return cb(false) end

    validateOwnedHuntingWagonRecord(charId, data, function(valid, wagonId)
        if not valid then return cb(false) end
        cargoStatus(wagonId, function(used, capacity)
            cb({ used = used, capacity = capacity })
        end)
    end)
end)

Core.Callback.Register('bcc-wagons:LoadHuntingCarcass', function(source, cb, data)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'hunting carcass load')
    if not charId or type(data) ~= 'table' then return cb(false, 'invalid') end

    local modelHash = tonumber(data.modelHash)
    local carcassKey = type(data.carcassKey) == 'string' and data.carcassKey or nil
    if not modelHash or not carcassKey or #carcassKey < 1 or #carcassKey > 64 then
        return cb(false, 'invalid')
    end

    validateOwnedHuntingWagon(src, charId, data, function(valid, wagonId)
        if not valid then return cb(false, 'invalid') end
        if ActiveLoads[wagonId] then return cb(false, 'busy') end
        ActiveLoads[wagonId] = true

        cargoStatus(wagonId, function(used, capacity)
            local units = getAnimalSize(modelHash)
            local quality = math.max(1, math.min(3, math.floor(tonumber(data.quality) or 1)))
            local isSkinned = data.isSkinned == true and 1 or 0
            local outfitHash = tonumber(data.outfitHash) or 0
            local metaTags = encodeMetaTags(data.metaTags)
            if used + units > capacity then
                ActiveLoads[wagonId] = nil
                return cb(false, 'full', { used = used, capacity = capacity })
            end

            MySQL.insert(
                ('INSERT IGNORE INTO `%s` (`wagon_id`, `carcass_key`, `model_hash`, `cargo_units`, `quality`, `is_skinned`, `outfit_hash`, `meta_tags`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'):format(CARGO_TABLE),
                { wagonId, carcassKey, modelHash, units, quality, isSkinned, outfitHash, metaTags },
                function(insertId)
                    ActiveLoads[wagonId] = nil
                    if not insertId or insertId <= 0 then return cb(false, 'duplicate') end
                    cb(true, nil, { used = used + units, capacity = capacity })
                end
            )
        end)
    end)
end)

local function restorePendingUnload(pending, callback)
    MySQL.insert(
        ('INSERT IGNORE INTO `%s` (`wagon_id`, `carcass_key`, `model_hash`, `cargo_units`, `quality`, `is_skinned`, `outfit_hash`, `meta_tags`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'):format(CARGO_TABLE),
        {
            pending.wagonId,
            pending.carcassKey,
            pending.modelHash,
            pending.units,
            pending.quality,
            pending.isSkinned and 1 or 0,
            pending.outfitHash,
            pending.metaTagsJson,
        },
        function()
            if callback then callback() end
        end
    )
end

Core.Callback.Register('bcc-wagons:ReserveHuntingCarcassUnload', function(source, cb, data)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'hunting carcass unload')
    if not charId then return cb(false) end

    validateOwnedHuntingWagon(src, charId, data, function(valid, wagonId)
        if not valid or ActiveLoads[wagonId] then return cb(false) end
        ActiveLoads[wagonId] = true

        MySQL.single(
            ('SELECT `id`, `carcass_key`, `model_hash`, `cargo_units`, `quality`, `is_skinned`, `outfit_hash`, `meta_tags` FROM `%s` WHERE `wagon_id` = ? ORDER BY `id` DESC LIMIT 1'):format(CARGO_TABLE),
            { wagonId },
            function(row)
                if not row then
                    ActiveLoads[wagonId] = nil
                    return cb(false)
                end

                MySQL.update(
                    ('DELETE FROM `%s` WHERE `id` = ? AND `wagon_id` = ?'):format(CARGO_TABLE),
                    { row.id, wagonId },
                    function(rowsAffected)
                        ActiveLoads[wagonId] = nil
                        if not rowsAffected or rowsAffected <= 0 then return cb(false) end

                        local token = ('%d:%d:%d:%d'):format(
                            src,
                            wagonId,
                            GetGameTimer(),
                            math.random(100000, 999999)
                        )
                        local pending = {
                            source = src,
                            wagonId = wagonId,
                            carcassKey = row.carcass_key,
                            modelHash = tonumber(row.model_hash),
                            units = math.max(1, tonumber(row.cargo_units) or 1),
                            quality = math.max(1, math.min(3, tonumber(row.quality) or 1)),
                            isSkinned = row.is_skinned == true
                                or tonumber(row.is_skinned) == 1,
                            outfitHash = tonumber(row.outfit_hash) or 0,
                            metaTagsJson = row.meta_tags,
                            metaTags = decodeMetaTags(row.meta_tags),
                        }
                        PendingUnloads[token] = pending

                        cargoStatus(wagonId, function(used, capacity)
                            cb(true, {
                                token = token,
                                modelHash = pending.modelHash,
                                quality = pending.quality,
                                isSkinned = pending.isSkinned,
                                outfitHash = pending.outfitHash,
                                metaTags = pending.metaTags,
                                status = { used = used, capacity = capacity },
                            })
                        end)

                        SetTimeout(15000, function()
                            if PendingUnloads[token] ~= pending then return end
                            PendingUnloads[token] = nil
                            restorePendingUnload(pending)
                        end)
                    end
                )
            end
        )
    end)
end)

Core.Callback.Register('bcc-wagons:FinalizeHuntingCarcassUnload', function(source, cb, data)
    local token = type(data) == 'table' and data.token
    local pending = token and PendingUnloads[token]
    if not pending or pending.source ~= source then return cb(false) end
    PendingUnloads[token] = nil

    if data.spawned == true then
        return cargoStatus(pending.wagonId, function(used, capacity)
            cb(true, { used = used, capacity = capacity })
        end)
    end

    restorePendingUnload(pending, function()
        cargoStatus(pending.wagonId, function(used, capacity)
            cb(false, { used = used, capacity = capacity })
        end)
    end)
end)

Core.Callback.Register('bcc-wagons:ClearHuntingCargoForTesting', function(source, cb, data)
    if not Config.development.enabled then return cb(false) end
    local _, charId = ServerUtils.getCharacter(source, 'hunting cargo test reset')
    if not charId then return cb(false) end

    validateOwnedHuntingWagon(source, charId, data, function(valid, wagonId)
        if not valid then return cb(false) end
        MySQL.update(
            ('DELETE FROM `%s` WHERE `wagon_id` = ?'):format(CARGO_TABLE),
            { wagonId },
            function()
                cb(true, { used = 0, capacity = cargoCapacity() })
            end
        )
    end)
end)

-- Keep the resource safe if the hunting table has not been imported yet.
-- database/schema.sql remains the canonical clean-install definition.
CreateThread(function()
    MySQL.query.await(([=[
        CREATE TABLE IF NOT EXISTS `%s` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `wagon_id` INT UNSIGNED NOT NULL,
            `carcass_key` VARCHAR(64) NOT NULL,
            `model_hash` BIGINT NOT NULL,
            `cargo_units` TINYINT UNSIGNED NOT NULL DEFAULT 1,
            `quality` TINYINT UNSIGNED NOT NULL DEFAULT 1,
            `is_skinned` TINYINT(1) NOT NULL DEFAULT 0,
            `outfit_hash` BIGINT NOT NULL DEFAULT 0,
            `meta_tags` LONGTEXT NULL,
            `stored_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_bcc_hunting_carcass` (`wagon_id`, `carcass_key`),
            KEY `idx_bcc_hunting_wagon` (`wagon_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]=]):format(CARGO_TABLE))
end)
