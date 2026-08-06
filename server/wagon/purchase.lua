local MAX_WAGON_NAME_LENGTH <const> = 100
local WAGONS_TABLE <const> = 'bcc_player_wagons'
local ActiveTransactions = {}

local function canPurchaseAtShop(src, siteId, model)
    local site = type(siteId) == 'string' and Sites[siteId]
    if not site then return false end

    local playerPed = GetPlayerPed(src)
    if playerPed == 0 or #(GetEntityCoords(playerPed) - site.npc.coords) > 10.0 then return false end

    if site.wainwrightBuy and not IsSourceAuthorizedWainwright(src) then return false end

    local characterState = Player(src).state.Character or {}
    local job = characterState.Job or 'unemployed'
    local grade = tonumber(characterState.Grade) or 0
    if site.shop.jobsEnabled and grade < (tonumber(site.shop.jobs[job]) or math.huge) then return false end

    local allowedJobs
    for jobName, models in pairs(Wagons.JobLocks or {}) do
        for _, lockedModel in ipairs(models) do
            if lockedModel == model then
                allowedJobs = allowedJobs or {}
                allowedJobs[jobName] = true
            end
        end
    end

    return not allowedJobs or allowedJobs[job] == true
end

local function maxWagonsForSource(src)
    return ServerUtils.getWagonLimit(src)
end

local function finishTransaction(charId, cb, success, result)
    ActiveTransactions[charId] = nil
    cb(success, result)
end

---@param src integer
---@param cb function
---@param context string
---@return table|nil character
---@return integer|nil charId
local function beginTransaction(src, cb, context)
    local character, charId = ServerUtils.getCharacter(src, context)
    if not character or not charId then
        cb(false, _U('characterUnavailable'))
        return nil, nil
    end

    if ActiveTransactions[charId] then
        cb(false, _U('transactionBusy'))
        return nil, nil
    end

    ActiveTransactions[charId] = true
    return character, charId
end

local function checkRosterCapacity(charId, src, cb, continuation, onRejected)
    MySQL.scalar(
        ('SELECT COUNT(*) FROM `%s` WHERE `charid` = ?'):format(WAGONS_TABLE),
        { charId },
        function(count)
            local limit = maxWagonsForSource(src)
            if (tonumber(count) or 0) >= limit then
                if onRejected then onRejected() end
                local message = _U('wagonLimit') .. limit .. _U('wagons')
                return finishTransaction(charId, cb, false, message)
            end

            continuation()
        end
    )
end

local function insertWagon(character, charId, data, price, currencyType, cb, successLog, onSuccess, onFailure)
    local modelConfig = ServerUtils.getWagonConfig(data.Model)
    local maxCondition = modelConfig and modelConfig.condition
        and tonumber(modelConfig.condition.maxAmount) or 100
    local query = ('INSERT INTO `%s` (`charid`, `name`, `model`, `condition`) VALUES (?, ?, ?, ?)')
        :format(WAGONS_TABLE)
    local parameters = { charId, data.name, data.Model, maxCondition }

    MySQL.insert(
        query,
        parameters,
        function(insertId)
            if not insertId or insertId <= 0 then
                if onFailure then onFailure() end
                return finishTransaction(charId, cb, false, _U('databaseWriteFailed'))
            end

            if price > 0 then
                character.removeCurrency(currencyType, price)
            end

            if onSuccess then onSuccess() end
            LogToDiscord(charId, successLog)
            finishTransaction(charId, cb, true, insertId)
        end
    )
end

local function validatePurchaseData(data)
    if type(data) ~= 'table' then return nil, _U('invalidPurchaseData') end

    local name = ServerUtils.normalizeName(data.name, MAX_WAGON_NAME_LENGTH)
    local modelConfig = ServerUtils.getWagonConfig(data.Model)

    if not name or not modelConfig then
        return nil, _U('invalidWagonConfig')
    end

    data.name = name
    return modelConfig
end

Core.Callback.Register('bcc-wagons:ProcessWagonPurchase', function(source, cb, data)
    local src = source
    local character, charId = beginTransaction(src, cb, 'wagon purchase callback')
    if not character or not charId then return end

    local modelConfig, validationError = validatePurchaseData(data)
    if not modelConfig then return finishTransaction(charId, cb, false, validationError) end
    if not canPurchaseAtShop(src, data.siteId, data.Model) then
        return finishTransaction(charId, cb, false, _U('purchaseNotAllowed'))
    end

    checkRosterCapacity(charId, src, cb, function()
        local configuredCurrency = tonumber(modelConfig.currency) or 3
        local currencyType = data.IsCash == true and 0 or 1

        if configuredCurrency == 1 then currencyType = 0 end
        if configuredCurrency == 2 then currencyType = 1 end

        local price = currencyType == 0
            and (tonumber(modelConfig.cashPrice) or 0)
            or (tonumber(modelConfig.goldPrice) or 0)

        if configuredCurrency == 4 then price = 0 end

        local balance = currencyType == 0 and tonumber(character.money) or tonumber(character.gold)
        if price > 0 and (balance or 0) < price then
            local message = currencyType == 0 and _U('shortCash') or _U('shortGold')
            return finishTransaction(charId, cb, false, message)
        end

        insertWagon(
            character,
            charId,
            data,
            price,
            currencyType,
            cb,
            ('Wagon purchased: %s (%s)'):format(data.Model, data.name)
        )
    end)
end)
