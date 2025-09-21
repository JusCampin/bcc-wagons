Config = {

    -- Set Language
    defaultlang = 'en_lang',
    -----------------------------------------------------

    devMode = {
        active = false,        -- Shows Debug Prints in Client and Server Consoles
        command = 'wagonStart' -- Command to Start Main Thread if devMode is active and resource is restarted
    },
    -----------------------------------------------------

    -- Which currancy type is allowed?
    -- 0 = Cash Only
    -- 1 = Gold Only
    -- 2 = Both
    currencyType = 2, -- Default: 2
    -----------------------------------------------------

    keys = {
        shop   = 0x760A9C6F, -- [G] Open Wagon Shop Menu
        ret    = 0xD9D0E1C0, -- [spacebar] Return Wagon at Shop
        call   = 0xF3830D8E, -- [J] Call Selected Wagon
        trade  = 0x27D1C284, -- [R] Complete Wagon Trade
        loot   = 0x760A9C6F, -- [G] Loot Wagon
        menu   = 0x63A0D258, -- [G] Open Wagon Menu
        action = 0x760A9C6F, -- [G] Open Wagon Menu Off Wagon
        brake  = 0xF1301666, -- [O] Set Brake
    },
    -----------------------------------------------------

    -- Change / Translate Wagons Commands
    commands = {
        wagonEnter  = 'wagonEnter', -- Enter Wagon if Unable to Access
        wagonReturn = 'wagonReturn' -- Return Wagon to Shop if 'returnEnabled' is true
    },
    -----------------------------------------------------

    -- Discord webhooks
    Webhook = '', --place your webhook url
    WebhookTitle = 'BCC-Wagons',
    WebhookAvatar = '',
    -----------------------------------------------------

    -- 1 = Miles per Hour (MPH)
    -- 2 = Kilometers per Hour (KPH)
    speed = 1, -- Default: 1
    -----------------------------------------------------

    -- Sell Price is 70% of cashPrice (shown below)
    sellPrice = 0.70, -- Default: 0.70
    -----------------------------------------------------

    -- Max Number of Wagons per Player
    maxWagons = {
        player = 5,     -- Default: 5
        wainwright = 10 -- Default: 10
    },
    -----------------------------------------------------

    -- Translate Label Only
    repair = {
        item = 'bcc_repair_hammer', -- Default: 'bcc_repair_hammer' / Item Name in Database for Repair Item
        label = 'Repair Hammer',    -- Default: 'Repair Hammer' / Item Label for Repair Item
        usage = 1,                  -- Default: 1 / Durability Value Removed from item per Use
    },
    -----------------------------------------------------

    -- Players Can Remote Call and Return Their Wagon
    callEnabled = true,   -- Default: true / Set to false to Spawn Wagon from Menu Only
    returnEnabled = true, -- Defauly: true / Set to false to Return at Wagon Dealer Only
    callDist = 100,       -- Default: 100 / Distance from Wagon to Call for Respawn
    -----------------------------------------------------

    -- Set Player in Wagon on Spawn from Menu
    seated = true, -- Default: true / Set to false to have Player Walk to Wagon
    -----------------------------------------------------

    -- Wainwright Job
    wainwrightOnly = false, -- *Not Currently Used*
    wainwrightJob = {
        { name = 'wainwright', grade = 0 },
    },
    -----------------------------------------------------

    --- Character Outfits at wagon
    outfitsAtWagon = false, -- Set to true if you want outfits accessible at the wagon
    ----------------------------------------------------

    BlipColors = {
        LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
        DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
        PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
        ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
        TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
        LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
        PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
        GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
        DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
        RED           = 'BLIP_MODIFIER_MP_COLOR_10',
        LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
        TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
        BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
        DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
        DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
        DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
        GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
        PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
        YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
        DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
        BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
        BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
        YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
        BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
        TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
        TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
        OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
        LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
        LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
        LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
        LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
        WHITE         = 'BLIP_MODIFIER_MP_COLOR_32'
    },
}
