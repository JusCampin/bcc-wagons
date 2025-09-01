local Core = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()
---@type BCCWagonsDebugLib
local DBG = BCCWagonsDebug or {
    Info = function() end,
    Error = function() end,
    Warning = function() end,
    Success = function() end
}

function OpenWagonMenu()
    local WagonMenu = FeatherMenu:RegisterMenu('bcc:wagons:menu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '350px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
        canclose = true
    }, {
        opened = function()
            DisplayRadar(false)
        end,
        closed = function()
            DisplayRadar(true)
        end
    })

    -----------------------------------------------------
    -- Main Page
    -----------------------------------------------------
    local MainPage = WagonMenu:RegisterPage('main:page')
    local RepairPage = WagonMenu:RegisterPage('repair:page')
    local ReturnPage = WagonMenu:RegisterPage('return:page')
    local TradePage = WagonMenu:RegisterPage('trade:page')
    local playerPed = PlayerPedId()

    MainPage:RegisterElement('header', {
        value = MyWagonName,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    MainPage:RegisterElement('subheader', {
        value = _U('wagonMenu'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    MainPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    MainPage:RegisterElement('button', {
        label = _U('repairWagon'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        if WagonCfg.condition.enabled then
            if RepairLevel < WagonCfg.condition.maxAmount then
                RepairPage:RouteTo()
            else
                Core.NotifyRightTip(_U('noRepairs'), 4000)
            end
        else
            Core.NotifyRightTip(_U('repairDisabled'), 4000)
        end
    end)

    MainPage:RegisterElement('button', {
        label = _U('cargo'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        if WagonCfg.inventory.enabled then
            TriggerServerEvent('bcc-wagons:OpenInventory', MyWagonId)
            WagonMenu:Close()
        else
            Core.NotifyRightTip(_U('cargoDisabled'), 4000)
        end
    end)

    if Config.returnEnabled then
        MainPage:RegisterElement('button', {
            label = _U('returnWagon'),
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            }
        }, function()
            ReturnPage:RouteTo()
        end)
    end

    MainPage:RegisterElement('button', {
        label = _U('startTrade'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        if not IsPedOnSpecificVehicle(playerPed, MyWagon) then
            if not Trading then
                TradePage:RouteTo()
            else
                Core.NotifyRightTip(_U('alreadyTrading'), 4000)
            end
        else
            Core.NotifyRightTip(_U('exitWagon'), 4000)
        end
    end)
	
    if Config.outfitsAtWagon then
        MainPage:RegisterElement('button', {
            label = _U('wagonOutfits'),
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            }
        }, function()
            TriggerServerEvent('bcc-wagons:GetOutfits')
        end)
    end
	
    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MainPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        WagonMenu:Close()
    end)

    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    -----------------------------------------------------
    -- Repair Page
    -----------------------------------------------------
    local function GetItemDurability()
        local result = Core.Callback.TriggerAwait('bcc-wagons:GetItemDurability', Config.repair.item)
        if result then
            return result
        else
            return 0
        end
    end
    local durability = GetItemDurability()

    RepairPage:RegisterElement('header', {
        value = MyWagonName,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    RepairPage:RegisterElement('subheader', {
        value = _U('repairWagon'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    RepairPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    RepairPage:RegisterElement('subheader', {
        value = _U('wagonCondition'),
        slot = 'header',
        style = {
            ['color'] = '#ddd'
        }
    })

    ConditionText = RepairPage:RegisterElement('textdisplay', {
        value = _U('max') .. WagonCfg.condition.maxAmount .. _U('current') .. RepairLevel,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw'
        }
    })

    DurabilityText = RepairPage:RegisterElement('textdisplay', {
        value = _U('toolDurability') .. tostring(durability) .. '%',
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw'
        }
    })

    RepairPage:RegisterElement('button', {
        label = _U('useTool'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function(data)
        if RepairLevel >= WagonCfg.condition.maxAmount then
            return Core.NotifyRightTip(_U('noRepairs'), 4000)
        end
        local newLevel = Core.Callback.TriggerAwait('bcc-wagons:RepairWagon', MyWagonId, MyWagonModel)
        if newLevel then
            RepairLevel = newLevel
            if IsWagonDamaged and (RepairLevel >= WagonCfg.condition.decreaseValue) then
                IsWagonDamaged = false
            end
        end
        ConditionText:update({
            value = _U('max') .. WagonCfg.condition.maxAmount .. _U('current') .. RepairLevel
        })
        DurabilityText:update({
            value = _U('toolDurability') .. tostring(GetItemDurability()) .. '%'
        })
    end)

    RepairPage:RegisterElement('button', {
        label = _U('refresh'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        ConditionText:update({
            value = _U('max') .. WagonCfg.condition.maxAmount .. _U('current') .. RepairLevel
        })
        DurabilityText:update({
            value = _U('toolDurability') .. tostring(GetItemDurability()) .. '%'
        })
    end)

    RepairPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    RepairPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        MainPage:RouteTo()
    end)

    RepairPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    -----------------------------------------------------
    -- Return Page
    -----------------------------------------------------
    ReturnPage:RegisterElement('header', {
        value = MyWagonName,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    ReturnPage:RegisterElement('subheader', {
        value = _U('returnWagon'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    ReturnPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local CancelReturn = true
    ReturnPage:RegisterElement('checkbox', {
        label = _U('confirm'),
        start = false,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function(data)
        if data.value == true then
            CancelReturn = false
            ReturnButton:update({
                label = _U('submit')
            })
        else
            CancelReturn = true
            ReturnButton:update({
                label = _U('back')
            })
        end
    end)

    ReturnPage:RegisterElement('textdisplay', {
        value = _U('remoteReturnText'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    })

    ReturnPage:RegisterElement('line', {
        slot = 'content',
        style = {}
    })

    ReturnPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    ReturnButton = ReturnPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        if CancelReturn then
            MainPage:RouteTo()
        else
            WagonMenu:Close()
            if IsPedOnSpecificVehicle(playerPed, MyWagon) then
                TaskLeaveVehicle(playerPed, MyWagon, 0)
                Wait(1000)
            end
            DoScreenFadeOut(500)
            Wait(500)
            ResetWagon()
            Wait(500)
            DoScreenFadeIn(500)
        end
    end)

    ReturnPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    WagonMenu:Open({
        startupPage = MainPage
    })

    -----------------------------------------------------
    -- Trade Page
    -----------------------------------------------------
    TradePage:RegisterElement('header', {
        value = MyWagonName,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    TradePage:RegisterElement('subheader', {
        value = _U('tradeWagon'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    TradePage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local CancelTrade = true
    TradePage:RegisterElement('checkbox', {
        label = _U('confirm'),
        start = false,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        if data.value == true then
            CancelTrade = false
            TradeButton:update({
                label = _U('submit'),
            })
        else
            CancelTrade = true
            TradeButton:update({
                label = _U('back'),
            })
        end
    end)

    TradePage:RegisterElement('textdisplay', {
        value = _U('standNearPlayer'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        }
    })

    TradePage:RegisterElement('line', {
        slot = 'content',
        style = {}
    })

    TradePage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TradeButton = TradePage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function()
        if CancelTrade then
            MainPage:RouteTo()
        else
            WagonMenu:Close()
            Core.NotifyRightTip(_U('readyToTrade'), 4000)
            Trading = true
            TriggerEvent('bcc-wagons:TradeWagon')
            StartTradePrompts()
        end
    end)

    TradePage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    WagonMenu:Open({
        startupPage = MainPage
    })
end