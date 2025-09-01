-- Wagon Shops
Sites = {
    valentine = {
        shop = {
            name        = 'Valentine Wagons',               -- Name of Shop on Menu
            prompt      = 'Valentine Wagons',               -- Text Below the Prompt Button
            distance    = 2.0,                              -- Distance from NPC to Get Menu Prompt
            jobsEnabled = false,                            -- Allow Shop Access to Specified Jobs Only
            jobs = {                                        -- Insert Job to limit access - ex. allowedJobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,                             -- Shop uses Open and Closed Hours
                open   = 7,                                 -- Shop Open Time / 24 Hour Clock
                close  = 21                                 -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name       = 'Valentine Wagons',                -- Name of Blip on Map
            sprite     = 1012165077,                        -- Default: 1258184551
            show = {
                open   = true,                              -- Show Blip On Map when Open
                closed = true,                              -- Show Blip On Map when Closed
            },
            color = {
                open   = 'WHITE',                           -- Shop Open - Default: White - Blip Colors Shown Below
                closed = 'RED',                             -- Shop Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE'                    -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                                -- Turns NPC On / Off
            model    = 's_m_m_coachtaxidriver_01',          -- Model Used for NPC
            coords   = vector3(-383.46, 792.91, 115.81),    -- NPC and Shop Blip Positions
            heading  = 14.37,                               -- NPC Heading
            distance = 100.0                                -- Distance Between Player and Shop for NPC to Spawn
        },
        wagon = {
            coords  = vector3(-392.81, 800.65, 115.86),     -- Wagon Spawn and Return Positions
            heading = 266.14,                               -- Wagon Spawn Heading
            camera  = vector3(-391.07, 794.49, 115.94)      -- Camera Location to View Wagon When In-Menu
        },
        wainwrightBuy = false,                              -- Only Wainwrights can Buy Wagons from this Shop
    },
    -----------------------------------------------------

    strawberry = {
        shop = {
            name        = 'Strawberry Wagons',
            prompt      = 'Strawberry Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Strawberry Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(-1831.53, -596.45, 154.48),
            heading  = 277.22,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(-1824.36, -601.47, 154.47),
            heading = 180.8,
            camera  = vector3(-1830.89, -604.33, 154.36),
        },
        wainwrightBuy = false,
    },
    -----------------------------------------------------

    vanhorn = {
        shop = {
            name        = 'Van Horn Wagons',
            prompt      = 'Van Horn Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Van Horn Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(2993.25, 783.33, 50.23),
            heading  = 97.4,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(2984.43, 780.76, 50.11),
            heading = 50.9,
            camera  = vector3(2989.72, 785.28, 50.13),
        },
        wainwrightBuy = false,
    },
    -----------------------------------------------------

    lemoyne = {
        shop = {
            name        = 'Lemoyne Wagons',
            prompt      = 'Lemoyne Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Lemoyne Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(1219.46, -195.59, 101.29),
            heading  = 295.81,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(1230.39, -198.39, 101.29),
            heading = 255.99,
            camera  = vector3(1227.33, -204.34, 100.89),
        },
        wainwrightBuy = false,
    },
    -----------------------------------------------------

    saintdenis = {
        shop = {
            name        = 'Saint Denis Wagons',
            prompt      = 'Saint Denis Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Saint Denis Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(2653.01, -1030.38, 44.87),
            heading  = 145.95,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(2657.36, -1038.59, 45.54),
            heading = 95.3,
            camera  = vector3(2653.01, -1032.47, 45.08),
        },
        wainwrightBuy = false,
    },
    -----------------------------------------------------

    blackwater = {
        shop = {
            name        = 'Blackwater Wagons',
            prompt      = 'Blackwater Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Blackwater Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(-876.06, -1374.64, 43.56),
            heading  = 180.44,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(-876.22, -1383.45, 43.48),
            heading = 98.35,
            camera  = vector3(-879.41, -1376.95, 43.58),
        },
        wainwrightBuy = false,
    },
    -----------------------------------------------------

    tumbleweed = {
        shop = {
            name        = 'Tumbleweed Wagons',
            prompt      = 'Tumbleweed Wagons',
            distance    = 2.0,
            jobsEnabled = false,
            jobs = {
                {name = 'police', grade = 1},
                {name = 'doctor', grade = 3}
            },
            hours = {
                active = false,
                open   = 7,
                close  = 21
            }
        },
        blip = {
            name       = 'Tumbleweed Wagons',
            sprite     = 1012165077,
            show = {
                open   = true,
                closed = true,
            },
            color = {
                open   = 'WHITE',
                closed = 'RED',
                job    = 'YELLOW_ORANGE'
            }
        },
        npc = {
            active   = true,
            model    = 's_m_m_coachtaxidriver_01',
            coords   = vector3(-5539.02, -3021.74, -1.32),
            heading  = 23.06,
            distance = 100.0
        },
        wagon = {
            coords  = vector3(-5547.98, -3020.25, -1.56),
            heading = 39.58,
            camera  = vector3(-5541.83, -3017.31, -1.23),
        },
        wainwrightBuy = false,
    }
}