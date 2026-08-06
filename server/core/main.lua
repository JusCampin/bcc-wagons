local WAGONS_TABLE <const> = 'bcc_player_wagons'
local MAX_WAGON_NAME_LENGTH <const> = 100

---@param wagonRow table
---@return table|nil
local function parseWagonRow(wagonRow)
    if type(wagonRow) ~= 'table' then return nil end

    local wagonId = tonumber(wagonRow.id)
    if not wagonId then return nil end

    return {
        id = wagonId,
        charid = tonumber(wagonRow.charid) or wagonRow.charid,
        name = wagonRow.name,
        model = wagonRow.model,
        condition = tonumber(wagonRow.condition) or 100,
        is_selected = ServerUtils.databaseBoolean(wagonRow.is_selected),
    }
end

local function selectWagonForCharacter(charId, wagonId, callback)
    MySQL.transaction({
        {
            query = ('UPDATE `%s` SET `is_selected` = 0 WHERE `charid` = ?'):format(WAGONS_TABLE),
            values = { charId },
        },
        {
            query = ('UPDATE `%s` SET `is_selected` = 1 WHERE `id` = ? AND `charid` = ?'):format(WAGONS_TABLE),
            values = { wagonId, charId },
        },
    }, callback)
end

Core.Callback.Register('bcc-wagons:GetSelectedWagonData', function(source, cb, request)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'selected wagon callback')
    if not charId then return cb(false) end

    local requestedWagonId = type(request) == 'table' and tonumber(request.wagonId) or nil

    local function returnWagon(wagonRow)
        local wagon = wagonRow and parseWagonRow(wagonRow)
        if not wagon then
            Core.NotifyRightTip(src, _U('noSelectedWagon'), 4000)
            return cb(false)
        end
        cb(wagon)
    end

    if not requestedWagonId then
        MySQL.single(
            ('SELECT `id`, `charid`, `name`, `model`, `condition`, `is_selected` FROM `%s` WHERE `charid` = ? AND `is_selected` = 1 LIMIT 1'):format(WAGONS_TABLE),
            { charId },
            returnWagon
        )
        return
    end

    MySQL.scalar(
        ('SELECT `id` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
        { requestedWagonId, charId },
        function(ownedWagonId)
            if tonumber(ownedWagonId) ~= requestedWagonId then return cb(false) end

            selectWagonForCharacter(charId, requestedWagonId, function(success)
                if not success then return cb(false) end

                MySQL.single(
                    ('SELECT `id`, `charid`, `name`, `model`, `condition`, `is_selected` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
                    { requestedWagonId, charId },
                    returnWagon
                )
            end)
        end
    )
end)

Core.Callback.Register('bcc-wagons:GetMyWagonsData', function(source, cb)
    local _, charId = ServerUtils.getCharacter(source, 'wagon roster callback')
    if not charId then return cb(false) end

    MySQL.query(
        ('SELECT `id`, `charid`, `name`, `model`, `condition`, `is_selected` FROM `%s` WHERE `charid` = ? ORDER BY `id` ASC'):format(WAGONS_TABLE),
        { charId },
        function(rows)
            local roster = {}
            for _, wagonRow in ipairs(rows or {}) do
                local wagon = parseWagonRow(wagonRow)
                if wagon then roster[#roster + 1] = wagon end
            end
            cb(roster)
        end
    )
end)

RegisterNetEvent('bcc-wagons:SelectActiveWagon', function(wagonId)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'wagon selection event')
    local targetWagonId = tonumber(wagonId)
    if not charId or not targetWagonId then
        DBG:Warning(('Invalid wagon selection received from source: %s'):format(tostring(src)))
        return
    end

    MySQL.scalar(
        ('SELECT `id` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
        { targetWagonId, charId },
        function(ownedWagonId)
            if tonumber(ownedWagonId) ~= targetWagonId then
                DBG:Warning(('Wagon selection rejected for source %s: wagon is not owned.'):format(tostring(src)))
                return
            end

            selectWagonForCharacter(charId, targetWagonId, function(success)
                if success then
                    DBG:Info('Wagon selection recorded for ID:', targetWagonId)
                else
                    DBG:Error(('Failed to select wagon ID %s for character %s.'):format(targetWagonId, charId))
                end
            end)
        end
    )
end)

Core.Callback.Register('bcc-wagons:RenameWagon', function(source, cb, data)
    local src = source
    local _, charId = ServerUtils.getCharacter(src, 'wagon rename callback')
    if not charId or type(data) ~= 'table' then return cb(false) end

    local wagonId = tonumber(data.wagonId)
    local newName = ServerUtils.normalizeName(data.newName, MAX_WAGON_NAME_LENGTH)
    if not wagonId or not newName then
        DBG:Warning(('Wagon rename rejected due to invalid data. Source: %s'):format(tostring(src)))
        return cb(false)
    end

    MySQL.update(
        ('UPDATE `%s` SET `name` = ? WHERE `id` = ? AND `charid` = ?'):format(WAGONS_TABLE),
        { newName, wagonId, charId },
        function(rowsAffected)
            if not rowsAffected or rowsAffected <= 0 then return cb(false) end

            DBG:Info('Wagon name recorded for ID:', wagonId)
            LogToDiscord(charId, ('Renamed wagon ID %d to: %s'):format(wagonId, newName))
            cb(true)
        end
    )
end)

RegisterNetEvent('vorp_core:instanceplayers', function(setRoom)
    if tonumber(setRoom) ~= 0 then return end

    local src = source
    local wagonData = Player(src).state.WagonData
    local currentNetId = wagonData and tonumber(wagonData.MyWagon)
    if currentNetId and currentNetId ~= 0 then
        TriggerClientEvent('bcc-wagons:UpdateMyWagonEntity', src, currentNetId)
    end
end)
