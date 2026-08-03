Wagons = Wagons or {}

local CURRENCY <const> = {
    CASH = 1,         -- The wagon can only be purchased with cash.
    GOLD = 2,         -- The wagon can only be purchased with gold.
    CASH_OR_GOLD = 3, -- The player chooses cash or gold at checkout.
    FREE = 4,         -- The wagon has no purchase cost.
}
-----------------------------------------------------

Wagons.TypeCatalog = {
    ['Buggies'] = {                    -- Category name shown on main menu page
        models = {
            ['buggy01'] = {            -- Model name of wagon
                label = 'Buggy 1',     -- Label to Display in Shop Menu
                distance = 5.0,        -- Distance from Wagon to Show Prompts / Open Menu
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 150,       -- Cash price can be left 0 if not used
                goldPrice = 7,         -- Gold price can be left 0 if not used
                invLimit = 200,        -- Inventory limit for wagon
                condition = {          -- Condition settings for wagon
                    enabled = true,    -- Set false to Disable Condition Decrease
                    maxAmount = 100,   -- Maximum Condition Value
                    decreaseValue = 1, -- Value to decrease Condition Level for Each 'decreaseTime' Interval
                    decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'decreaseValue'
                    repairValue = 25   -- Value to Increase Condition by When Using Repair Item
                }
            },
            ['buggy02'] = {
                label = 'Buggy 2',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 200,
                goldPrice = 10,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['buggy03'] = {
                label = 'Buggy 3',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 250,
                goldPrice = 12,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            }
        }
    },
    -----------------------------------------------------

    ['Coaches'] = {
        models = {
            ['coach3'] = {
                label = 'Coach 3',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 400,
                goldPrice = 19,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['coach4'] = {
                label = 'Coach 4',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 300,
                goldPrice = 14,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['coach5'] = {
                label = 'Coach 5',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 350,
                goldPrice = 17,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['coach6'] = {
                label = 'Coach 6',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 300,
                goldPrice = 14,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            }
        }
    },
    -----------------------------------------------------

    ['Carts'] = {
        models = {
            ['cart01'] = {
                label = 'Cart 1',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 450,
                goldPrice = 22,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart02'] = {
                label = 'Cart 2',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 100,
                goldPrice = 5,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart03'] = {
                label = 'Cart 3',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 450,
                goldPrice = 22,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart04'] = {
                label = 'Cart 4',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 550,
                goldPrice = 26,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart06'] = {
                label = 'Cart 6',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 650,
                goldPrice = 31,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart07'] = {
                label = 'Cart 7',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 400,
                goldPrice = 19,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['cart08'] = {
                label = 'Cart 8',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 400,
                goldPrice = 19,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['huntercart01'] = {
                label = 'Hunter Cart',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 650,
                goldPrice = 31,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            }
        }
    },
    -----------------------------------------------------

    ['Wagons'] = {
        models = {
            ['supplywagon'] = {
                label = 'Supply Wagon',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 950,
                goldPrice = 46,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagontraveller01x'] = {
                label = 'Travel Wagon',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1950,
                goldPrice = 94,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagon02x'] = {
                label = 'Wagon 2',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1250,
                goldPrice = 60,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagon03x'] = {
                label = 'Wagon 3',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1050,
                goldPrice = 51,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagon04x'] = {
                label = 'Wagon 4',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1250,
                goldPrice = 60,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagon05x'] = {
                label = 'Wagon 5',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1050,
                goldPrice = 51,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['wagon06x'] = {
                label = 'Wagon 6',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1250,
                goldPrice = 60,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['chuckwagon000x'] = {
                label = 'Chuck Wagon 1',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1500,
                goldPrice = 73,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            },
            ['chuckwagon002x'] = {
                label = 'Chuck Wagon 2',
                distance = 5.0,
                currency = CURRENCY.CASH_OR_GOLD,
                cashPrice = 1500,
                goldPrice = 73,
                invLimit = 200,
                condition = {
                    enabled = true,
                    maxAmount = 100,
                    decreaseValue = 1,
                    decreaseTime = 60,
                    repairValue = 25
                }
            }
        }
    }
}
-----------------------------------------------------

-- Restrict specific wagons to specific jobs
Wagons.JobLocks = {
    -- ['police'] = {
    --     'buggy01',
    --     -- Just drop any other police wagon models here as standard comma-separated strings
    -- },
    -- ['doctor'] = {
    --     'buggy01',
    -- }
}
-----------------------------------------------------

-- Ordered list of all wagon types in use
Wagons.TypeOrder = {
    'Buggies',
    'Coaches',
    'Carts',
    'Wagons'
}
-----------------------------------------------------

-- All used wagon models mapped to their types
Wagons.ModelToTypeMap = {
    ['buggy01']           = { wagonType = 'Buggies' },
    ['buggy02']           = { wagonType = 'Buggies' },
    ['buggy03']           = { wagonType = 'Buggies' },
    ['coach3']            = { wagonType = 'Coaches' },
    ['coach4']            = { wagonType = 'Coaches' },
    ['coach5']            = { wagonType = 'Coaches' },
    ['coach6']            = { wagonType = 'Coaches' },
    ['cart01']            = { wagonType = 'Carts' },
    ['cart02']            = { wagonType = 'Carts' },
    ['cart03']            = { wagonType = 'Carts' },
    ['cart04']            = { wagonType = 'Carts' },
    ['cart06']            = { wagonType = 'Carts' },
    ['cart07']            = { wagonType = 'Carts' },
    ['cart08']            = { wagonType = 'Carts' },
    ['supplywagon']       = { wagonType = 'Wagons' },
    ['wagontraveller01x'] = { wagonType = 'Wagons' },
    ['wagon02x']          = { wagonType = 'Wagons' },
    ['wagon03x']          = { wagonType = 'Wagons' },
    ['wagon04x']          = { wagonType = 'Wagons' },
    ['wagon05x']          = { wagonType = 'Wagons' },
    ['wagon06x']          = { wagonType = 'Wagons' },
    ['chuckwagon000x']    = { wagonType = 'Wagons' },
    ['chuckwagon002x']    = { wagonType = 'Wagons' }
}
