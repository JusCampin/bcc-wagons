Wagons = { -- Gold to Dollar Ratio Based on 1899 Gold Price / sellPrice is 60% of cashPrice
    -----------------------------------------------------
    -- Buggies
    -----------------------------------------------------
    {
        name  = 'Buggies',
        types = {                                    -- Only Players with Specified Job will See that Wagon to Purchase in the Menu
            ['buggy01'] = {
                label = 'Buggy 1',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 150,                     -- Purchase Price in Cash
                goldPrice = 7,                       -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 50,     -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,  -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['buggy02'] = {
                label = 'Buggy 2',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 200,                     -- Purchase Price in Cash
                goldPrice = 10,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 50,     -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,  -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['buggy03'] = {
                label = 'Buggy 3',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 250,                     -- Purchase Price in Cash
                goldPrice = 12,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 50,     -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,  -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
        }
    },
    -----------------------------------------------------
    -- Coaches
    -----------------------------------------------------
    {
        name = 'Coaches',
        types = {
            ['coach3'] = {
                label = 'Coach 3',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 400,                     -- Purchase Price in Cash
                goldPrice = 19,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 100,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,  -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['coach4'] = {
                label = 'Coach 4',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 300,                     -- Purchase Price in Cash
                goldPrice = 14,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 100,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,  -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['coach5'] = {
                label = 'Coach 5',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 350,                     -- Purchase Price in Cash
                goldPrice = 17,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 100,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['coach6'] = {
                label = 'Coach 6',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 300,                     -- Purchase Price in Cash
                goldPrice = 14,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 100,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
        }
    },
    -----------------------------------------------------
    -- Carts
    -----------------------------------------------------
    {
        name = 'Carts',
        types = {
            ['cart01'] = {
                label = 'Cart 1',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 450,                     -- Purchase Price in Cash
                goldPrice = 22,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart02'] = {
                label = 'Cart 2',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 100,                     -- Purchase Price in Cash
                goldPrice = 5,                       -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart03'] = {
                label = 'Cart 3',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 450,                     -- Purchase Price in Cash
                goldPrice = 22,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart04'] = {
                label = 'Cart 4',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 550,                     -- Purchase Price in Cash
                goldPrice = 26,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart06'] = {
                label = 'Cart 6',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 650,                     -- Purchase Price in Cash
                goldPrice = 31,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart07'] = {
                label = 'Cart 7',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 400,                     -- Purchase Price in Cash
                goldPrice = 19,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['cart08'] = {
                label = 'Cart 8',                    -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 400,                     -- Purchase Price in Cash
                goldPrice = 19,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['huntercart01'] = {
                label = 'Hunter Cart',               -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 650,                     -- Purchase Price in Cash
                goldPrice = 31,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 200,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
        }
    },
    -----------------------------------------------------
    -- Wagons
    -----------------------------------------------------
    {
        name = 'Wagons',
        types = {
            ['supplywagon'] = {
                label = 'Supply Wagon',              -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 950,                     -- Purchase Price in Cash
                goldPrice = 46,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagontraveller01x'] = {
                label = 'Travel Wagon',              -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1950,                    -- Purchase Price in Cash
                goldPrice = 94,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagon02x'] = {
                label = 'Wagon 2',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1250,                    -- Purchase Price in Cash
                goldPrice = 60,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagon03x'] = {
                label = 'Wagon 3',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1050,                    -- Purchase Price in Cash
                goldPrice = 51,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagon04x'] = {
                label = 'Wagon 4',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1250,                    -- Purchase Price in Cash
                goldPrice = 60,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagon05x'] = {
                label = 'Wagon 5',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1050,                    -- Purchase Price in Cash
                goldPrice = 51,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['wagon06x'] = {
                label = 'Wagon 6',                   -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1250,                    -- Purchase Price in Cash
                goldPrice = 60,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['chuckwagon000x'] = {
                label = 'Chuck Wagon 1',             -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1500,                    -- Purchase Price in Cash
                goldPrice = 73,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------

            ['chuckwagon002x'] = {
                label = 'Chuck Wagon 2',             -- Label to Display in Shop Menu
                distance = 5,                        -- Default: 5 / Distance from Wagon to Show Prompts / Open Menu
                cashPrice = 1500,                    -- Purchase Price in Cash
                goldPrice = 73,                      -- Purchase Price in Gold
                brakeSet = true,                     -- Default: true / Set to false to Spawn Wagon with Brake Released
                blip = {
                    enabled = true,                  -- Set false to Disable Blip
                    sprite = 'blip_mp_player_wagon', -- Default: 'blip_mp_player_wagon'
                },
                gamerTag = {
                    enabled = true, -- Default: true / Places Wagon Name Above Wagon When Empty
                    distance = 15   -- Default: 15 / Distance from Wagon to Show Tag
                },
                condition = {
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                },
                inventory = {
                    enabled = true, -- Set false to Disable Inventory
                    limit = 400,    -- Maximum Inventory Limit
                    weapons = true, -- Set false to Disable Weapons
                    shared = true,   -- Set false to Disable Shared Inventory
                    whitelistWeapons = false, -- Default: false / Set to true to Enable White List for Weapons
                    weaponsLimitWhiteList = {
                        -- { name = 'WEAPON_MELEE_TORCH', limit = 1, },
                    },
                    useBlackList = false, -- Default: false / Set to false to Disable
                    itemsBlackList = {
                        -- 'food_delivery1',
                        -- 'food_delivery2',
                        -- 'food_delivery3',
                    },
                    ignoreItemStackLimit = true, -- Default: true / Set to true to Ignore Item Stack Limit
                    useWhiteList = false, -- Default: false / Set to true to Enable White List
                    itemsLimitWhiteList = {
                        -- { name = 'diamond', limit = 10, },
                    },
                    usePermissions = false, -- Default: false / Set to true to Enable Permissions
                    permissions = {
                        allowedJobsTakeFrom = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                        allowedJobsMoveTo = {
                            -- { name = "police", grade = 0 },
                            -- { name = "sheriff", grade = 0 },
                        },
                    },
                },
                -- Only Players with Specified Job will See that wagon to Purchase in the Shop Menu
                job = {} -- Job Example: {'police', 'doctor'}
            },
            -----------------------------------------------------
        }
    }
}
