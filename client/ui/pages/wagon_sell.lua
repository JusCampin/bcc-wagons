local function getSaleQuote(wagon)
    local wagonType, model = ShopUI.GetModel(wagon.model)
    if not model then return nil end

    local multiplier = tonumber(Config.sales.wagonPriceMultiplier)

    return {
        wagonType = wagonType or 'Unknown',
        currency = tonumber(model.currency) or 3,
        cash = math.ceil((tonumber(model.cashPrice) or 0) * (multiplier or 0)),
        gold = math.ceil((tonumber(model.goldPrice) or 0) * (multiplier or 0)),
    }
end

local function formatPayout(quote, useCash)
    if quote.currency == 4 then return _U('noPayout') end
    return useCash
        and (_U('cashAmount') .. tostring(quote.cash))
        or (tostring(quote.gold) .. _U('goldAmount'))
end

--- @param wagon table
function BuildWagonSellPage(wagon)
    local quote = type(wagon) == 'table' and getSaleQuote(wagon)
    if not quote then
        Core.NotifyRightTip(_U('saleInfoUnavailable'), 4000)
        return false
    end

    local page = ShopUI.RegisterPage('wagon_sell')
    local pending = false
    local useCash = quote.currency ~= 2
    local wagonName = wagon.name or (_U('wagonNumber') .. tostring(wagon.id))

    ShopUI.AddHeader(page, _U('confirmWagonSale'))

    ShopUI.AddText(page, 'wagon_sale_identity',
        _U('saleIdentity') .. wagonName .. '\n' .. _U('wagonType') .. quote.wagonType
    )

    page:RegisterElement('line', { slot = 'content' })

    local payoutDisplay = ShopUI.AddText(
        page,
        'wagon_sale_payout',
        _U('payoutLabel') .. formatPayout(quote, useCash),
        quote.currency == 4 and ShopUI.Styles.text or ShopUI.Styles.success
    )

    if quote.currency == 3 then
        page:RegisterElement('arrows', {
            id = 'wagon_sale_currency',
            label = _U('currency'),
            slot = 'content',
            start = 1,
            options = {
                { display = _U('cash'), extra = true },
                { display = _U('gold'), extra = false },
            },
            persist = true,
        }, function(selection)
            useCash = selection.value.extra
            payoutDisplay:update({ value = _U('payoutLabel') .. formatPayout(quote, useCash) })
        end)
    end

    ShopUI.AddButton(page, 'wagon_sale_confirm', _U('confirmSale'), 'content', function()
        if pending then return end
        pending = true

        Core.Callback.TriggerAsync('bcc-wagons:SellMyWagon', function(success)
            pending = false
            if not success then
                Core.NotifyRightTip(_U('saleFailed'), 4000)
                return
            end

            StopRotation()
            ClearShopWagon()
            RemoveCachedWagon(wagon.id)
            ExpandedWagonId = nil
            FetchRosterAndAction(function()
                BuildMyWagonsPage()
                ShopUI.OpenPage('my_wagons')
            end)
        end, { wagonId = tonumber(wagon.id), isCashPayout = useCash })
    end, ShopUI.Styles.danger)

    ShopUI.AddFooter(page)

    ShopUI.AddButton(page, 'wagon_sale_rotate', '↻ ' .. _U('rotateButton'), 'footer', function()
        ShopUI.ToggleRotation(-1)
    end)

    ShopUI.AddButton(page, 'wagon_sale_back', _U('backButton'), 'footer', function()
        if pending then return end
        StopRotation()
        BuildMyWagonsPage()
        ShopUI.OpenPage('my_wagons')
    end)
    return true
end
