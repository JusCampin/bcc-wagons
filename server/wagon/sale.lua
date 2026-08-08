local ActiveSales = {}
local WAGONS_TABLE <const> = 'bcc_player_wagons'

local function saleKey(charId, wagonId)
    return ('%s:%s'):format(charId, wagonId)
end

local function payoutCharacter(character, currencyType, amount)
    if amount > 0 then
        character.addCurrency(currencyType, amount)
    end
end

Core.Callback.Register('bcc-wagons:SellMyWagon', function(source, cb, data)
    local src = source
    local character, charId = ServerUtils.getCharacter(src, 'owned wagon sale callback')
    if not character or not charId or type(data) ~= 'table' then return cb(false) end

    local wagonId = tonumber(data.wagonId)
    if not wagonId then return cb(false) end

    local lockKey = saleKey(charId, wagonId)
    if ActiveSales[lockKey] then return cb(false) end
    ActiveSales[lockKey] = true

    MySQL.single(
        ('SELECT `model` FROM `%s` WHERE `id` = ? AND `charid` = ? LIMIT 1'):format(WAGONS_TABLE),
        { wagonId, charId },
        function(row)
            if not row then
                ActiveSales[lockKey] = nil
                return cb(false)
            end

            local modelConfig = ServerUtils.getWagonConfig(row.model)
            if not modelConfig then
                ActiveSales[lockKey] = nil
                return cb(false)
            end

            local multiplier = (tonumber(Config.sales.wagonPriceMultiplier) or 0.5)
            local configuredCurrency = tonumber(modelConfig.currency) or 3
            local currencyType = data.isCashPayout == true and 0 or 1

            if configuredCurrency == 1 then currencyType = 0 end
            if configuredCurrency == 2 then currencyType = 1 end

            local basePrice = currencyType == 0
                and (tonumber(modelConfig.cashPrice) or 0)
                or (tonumber(modelConfig.goldPrice) or 0)
            local payout = configuredCurrency == 4 and 0 or math.max(0, math.ceil(basePrice * multiplier))

            MySQL.update(
                ('DELETE FROM `%s` WHERE `id` = ? AND `charid` = ?'):format(WAGONS_TABLE),
                { wagonId, charId },
                function(rowsAffected)
                    ActiveSales[lockKey] = nil
                    if not rowsAffected or rowsAffected <= 0 then return cb(false) end

                    MySQL.update(
                        'DELETE FROM `bcc_wagon_hunting_cargo` WHERE `wagon_id` = ?',
                        { wagonId }
                    )
                    payoutCharacter(character, currencyType, payout)

                    local message = payout > 0
                        and (currencyType == 0 and _U('wagonSoldCash', payout) or _U('wagonSoldGold', payout))
                        or _U('wagonReturnedToShop')
                    Core.NotifyRightTip(src, message, 4000)
                    LogToDiscord(charId, ('Wagon sold: ID %d (%s)'):format(wagonId, row.model))
                    cb(true)
                end
            )
        end
    )
end)
