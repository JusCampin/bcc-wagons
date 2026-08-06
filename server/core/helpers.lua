ServerUtils = ServerUtils or {}

---@param value string|table|nil
---@param fallback table
---@return table
function ServerUtils.decodeTable(value, fallback)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return fallback end

    local success, decoded = pcall(json.decode, value)
    if success and type(decoded) == 'table' then
        return decoded
    end

    DBG:Warning('Invalid JSON found in persisted data; using the supplied fallback.')
    return fallback
end

---@param value any
---@return boolean
function ServerUtils.databaseBoolean(value)
    return value == true or tonumber(value) == 1
end

---@param sourceId integer
---@param context string
---@return table|nil character
---@return integer|nil charId
function ServerUtils.getCharacter(sourceId, context)
    local user = Core.getUser(sourceId)
    if not user then
        DBG:Error(('User not found for %s. Source: %s'):format(context, tostring(sourceId)))
        return nil, nil
    end

    local character = user.getUsedCharacter
    if not character then
        DBG:Error(('Character not found for %s. Source: %s'):format(context, tostring(sourceId)))
        return nil, nil
    end

    local charId = tonumber(character.charIdentifier)
    if not charId then
        DBG:Error(('Invalid character identifier for %s. Source: %s'):format(context, tostring(sourceId)))
        return nil, nil
    end

    return character, charId
end

---@param model string
---@return table|nil modelConfig
---@return string|nil typeName
function ServerUtils.getWagonConfig(model)
    if type(model) ~= 'string' or model == '' then return nil, nil end

    local mapping = Wagons.ModelToTypeMap and Wagons.ModelToTypeMap[model]
    local typeName = mapping and mapping.wagonType
    local catalog = typeName and Wagons.TypeCatalog and Wagons.TypeCatalog[typeName]
    local modelConfig = catalog and catalog.models and catalog.models[model]

    return modelConfig, typeName
end

---@param value any
---@param maxLength integer|nil
---@return string|nil
function ServerUtils.normalizeName(value, maxLength)
    if type(value) ~= 'string' then return nil end

    local normalized = value:match('^%s*(.-)%s*$')
    if normalized == '' or #normalized > (maxLength or 100) then return nil end
    return normalized
end

---@param sourceId integer
---@return integer
function ServerUtils.getWagonLimit(sourceId)
    return IsSourceAuthorizedWainwright(sourceId)
        and (tonumber(Config.wagonLimits.wainwright) or 10)
        or (tonumber(Config.wagonLimits.player) or 5)
end

-- Discord logging
if Config.integrations.discord.enabled == true then
    Discord = BccUtils.Discord.setup(
        Config.integrations.discord.webhookUrl,
        Config.integrations.discord.title,
        Config.integrations.discord.avatarUrl
    )
end

function LogToDiscord(name, description, embeds)
    if Config.integrations.discord.enabled == true then
        Discord:sendMessage(name, description, embeds)
    end
end

function IsSourceAuthorizedWainwright(src)
    local characterState = Player(src).state.Character
    if not characterState then return false end

    local activeJob = characterState.Job or 'unemployed'
    local activeGrade = tonumber(characterState.Grade) or 0

    local wainwrightConfig = Config.wainwright.wainwrightJobs[activeJob]
    local minimumRequiredGrade = type(wainwrightConfig) == 'table'
        and wainwrightConfig.minimumGrade
        or wainwrightConfig
    if minimumRequiredGrade and activeGrade >= minimumRequiredGrade then
        return true
    end

    return false
end

---@param src integer
---@return table|nil profile
function GetSourceWainwrightProfile(src)
    local characterState = Player(src).state.Character
    if not characterState then return nil end

    local profile = Config.wainwright.wainwrightJobs[characterState.Job or 'unemployed']
    local minimumGrade = type(profile) == 'table' and profile.minimumGrade or profile
    if minimumGrade == nil or (tonumber(characterState.Grade) or 0) < minimumGrade then return nil end

    if type(profile) ~= 'table' then
        return { minimumGrade = minimumGrade}
    end

    return profile
end

CreateThread(function()
    for modelName in pairs(Wagons.ModelToTypeMap or {}) do
        local modelIntegerHash = joaat(modelName)
        InverseModelHashMap[modelIntegerHash] = modelName
    end

    DBG:Info('Model hash registry successfully compiled.')
end)
