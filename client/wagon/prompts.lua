ShopPrompt, CallPrompt, ReturnPrompt = 0, 0, 0
ShopGroup = GetRandomIntInRange(0, 0xffffff)

TradePrompt = 0
TradeGroup = GetRandomIntInRange(0, 0xffffff)

LootPrompt = 0
LootGroup = GetRandomIntInRange(0, 0xffffff)

OnWagonMenuPrompt, SetBrakePrompt, ReleaseBrakePrompt = 0, 0, 0
OnWagonGroup = GetRandomIntInRange(0, 0xffffff)

OffWagonMenuPrompt = 0
OffWagonGroup = GetRandomIntInRange(0, 0xffffff)

local promptGroupsInitialized = false

local keys <const> = Config.controls

local function promptText(localeKey)
    return CreateVarString(10, 'LITERAL_STRING', _U(localeKey))
end

local function registerPrompt(control, text, group, holdDuration, enabled)
    local prompt = UiPromptRegisterBegin()

    UiPromptSetControlAction(prompt, control)
    UiPromptSetText(prompt, text)
    UiPromptSetVisible(prompt, true)

    if enabled ~= nil then
        UiPromptSetEnabled(prompt, enabled)
    end

    if holdDuration then
        UiPromptSetHoldMode(prompt, holdDuration)
    else
        UiPromptSetStandardMode(prompt, true)
    end

    if group then
        UiPromptSetGroup(prompt, group, 0)
    end

    UiPromptRegisterEnd(prompt)
    return prompt
end

function StartPrompts()
    if promptGroupsInitialized then return end

    ShopPrompt = registerPrompt(keys.openShop, promptText('shopPrompt'), ShopGroup)
    CallPrompt = registerPrompt(keys.shopAction, promptText('callPrompt'), ShopGroup)
    ReturnPrompt = registerPrompt(keys.shopAction, promptText('returnPrompt'), ShopGroup)

    TradePrompt = registerPrompt(keys.tradeWagon, promptText('tradePrompt'), TradeGroup, 2000, true)

    LootPrompt = registerPrompt(keys.lootWagon, promptText('lootWagonPrompt'), LootGroup, nil, true)

    OnWagonMenuPrompt = registerPrompt(keys.onWagonMenu, promptText('wagonMenuPrompt'), OnWagonGroup)
    SetBrakePrompt = registerPrompt(keys.brakeAction, promptText('setBrakePrompt'), OnWagonGroup)
    ReleaseBrakePrompt = registerPrompt(keys.brakeAction, promptText('releaseBrakePrompt'), OnWagonGroup)

    OffWagonMenuPrompt = registerPrompt(keys.offWagonMenu, promptText('wagonMenuPrompt'), OffWagonGroup)

    promptGroupsInitialized = true
end
