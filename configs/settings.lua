Config = {

    -- Language file used for player-facing text.
    locale = 'en_lang',
    -----------------------------------------------------

    development = {
        -- Enables debug logs and test commands. Disable on live servers.
        enabled = true, -- Shows Debug Prints in Client and Server Consoles
    },
    -----------------------------------------------------

    integrations = {
        discord = {
            enabled = false,      -- Send configured shop events to Discord.
            webhookUrl = '',      -- Discord webhook URL. Keep blank when disabled.
            title = 'BCC-Wagons', -- Name shown above Discord log messages.
            avatarUrl = '',       -- Optional image URL used as the webhook avatar.
        },
    },
    -----------------------------------------------------

    -- Keyboard controls use RedM input hashes.
    controls = {
        openShop     = 0x760A9C6F, -- G: Open Wagon Shop Menu
        shopAction   = 0xD9D0E1C0, -- spacebar: Call/Return Active Wagon at Shop
        callWagon    = 0xF3830D8E, -- J: Call Selected Wagon
        tradeWagon   = 0x27D1C284, -- R: Complete Wagon Trade
        lootWagon    = 0x760A9C6F, -- G: Loot Wagon
        onWagonMenu  = 0x63A0D258, -- G: Open Wagon Menu
        offWagonMenu = 0x760A9C6F, -- G: Open Wagon Menu Off Wagon
        brakeAction  = 0xF1301666, -- O: Set/Release wagon brake
    },
    -----------------------------------------------------

    preview = {
        -- Each player receives a private routing bucket while viewing shop wagons.
        bucketBase = 7000,

        -- Default preview framing. Individual shops may override these values.
        camera = {
            referenceFov = 42.0,       -- Baseline field of view used for automatic scaling.
            referenceDistance = 4.75,  -- Distance paired with the baseline field of view.
            distance = 3.25,           -- Default camera distance from the preview wagon.
            minimumFov = 30.0,         -- Narrowest field of view automatic scaling may use.
            maximumFov = 65.0,         -- Widest field of view automatic scaling may use.
            horizontalOffset = 0.85,   -- Positive values move the wagon right on screen.
            cameraHeightOffset = 0.20, -- Raises or lowers the camera from the shop camera point.
            targetHeightOffset = 0.05, -- Raises or lowers where the camera aims on the wagon.
        },
    },
    -----------------------------------------------------

    -- Change / Translate Wagons Commands
    commands = {
        wagonEnter  = 'wagonEnter',  -- Enter Wagon if Unable to Access
        wagonReturn = 'wagonReturn', -- Return Wagon to Shop if 'returnEnabled' is true
        wagonReload = 'wagonReload'  -- Start Main Thread if development mode is enabled and resource is restarted
    },
    -----------------------------------------------------

    -- Discord webhooks
    Webhook = '', --place your webhook url
    WebhookTitle = 'BCC-Wagons',
    WebhookAvatar = '',
    -----------------------------------------------------

    shop = {
        -- Press the configured callWagon control (J by default) to call the
        -- active wagon. If it is not spawned, the selected owned wagon spawns.
        callActiveWagon = {
            enabled = true,
        },

        -- Allow players to dismiss their wagon through the Flee prompt.
        fleeEnabled = true,

        -- Actions that remain available while a shop is closed.
        whileClosed = {
            callWagon = true,   -- Allow calling a wagon while the shop is closed.
            returnWagon = true, -- Allow returning a wagon while the shop is closed.
        },

        -- Return a wagon to the shop when it becomes too far from its owner.
        autoReturn = {
            enabled = true,          -- Despawn wagons left too far from their owner.
            maximumDistance = 100.0, -- Maximum owner distance before auto-return.
            excludedModels = {
                -- Hunting carts remain where they are left while the owner
                -- travels away to hunt. Network control may migrate without
                -- changing gameplay ownership.
                ['huntercart01'] = true,
            },
        },

        -- Controls queued delivery from a shop spawn point to its delivery point.
        delivery = {
            reservationTimeoutMs = 15000, -- Maximum time one delivery reserves a spawn point.
            spawnClearance = 4.0,         -- Distance required before the next wagon may spawn.
            walkSpeed = 1.25,             -- Speed used while walking to the delivery point.
            arrivalDistance = 2.5,        -- Distance from the destination considered delivered.
        },
    },
    -----------------------------------------------------

    -- 1 = Miles per Hour (MPH)
    -- 2 = Kilometers per Hour (KPH)
    speed = 1, -- Default: 1
    -----------------------------------------------------

    -- Sell Price is 70% of cashPrice (shown below)
    sellPrice = 0.70, -- Default: 0.70
    -----------------------------------------------------

    wagonLimits = {
        player = 5,     -- Maximum wagons owned by a normal player.
        wainwright = 10 -- Maximum wagons owned by a configured wainwright.
    },
    -----------------------------------------------------

    wagonTag = {
        enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
        distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
    },
    -----------------------------------------------------

    wagonBlip = {
        enabled = true,                  -- Set false to Disable Blip
        sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
    },
    -----------------------------------------------------

    -- Native hunting cargo behavior for the Hunter Cart.
    huntingWagon = {
        enabled = true,
        model = 'huntercart01',
        nativeInteractionEnabled = false, -- Experimental: currently crashes when a carcass is picked up.
        tarpPropSet = 'pg_mp005_huntingWagonTarp01',
        initialTarpHeight = 0.0,
        tarpInitializationDelayMs = 500, -- Allow the added prop set to finish loading before setting its height.
        capacity = 6,
        defaultAnimalSize = 1,
        interactionDistance = 2.0,
        rearOffset = { x = 0.0, y = -2.25, z = 0.0 },
        loadPromptControl = 0x760A9C6F, -- G
        loadPromptHoldMs = 1000,
        loadAnimationMs = 1600,
    },
    -----------------------------------------------------

    --setBrake = true, -- Default: true / Set to false to Spawn Wagon with Brake Released
    -----------------------------------------------------

    -- Translate Label Only
    repair = {
        item = 'bcc_repair_hammer', -- Default: 'bcc_repair_hammer' / Item Name in Database for Repair Item
        label = 'Repair Hammer',    -- Default: 'Repair Hammer' / Item Label for Repair Item
        usage = 1,                  -- Default: 1 / Durability Value Removed from item per Use
    },
    -----------------------------------------------------

    sales = {
        -- Percentage of the catalog price returned when selling a wagon.
        wagonPriceMultiplier = 0.70,
    },
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
}
