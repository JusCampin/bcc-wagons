local function formatWagonPrice(model, useCash)
    local currency = tonumber(model.currency) or 3
    if currency == 4 then return _U('free') end
    return useCash
        and _U('cashAmount', tonumber(model.cashPrice) or 0)
        or _U('goldAmount', tonumber(model.goldPrice) or 0)
end

function BuildShopPurchasePage()
    local typeName = SelectedTypeName
    local model = SelectedModelKey
    local wagonType = typeName and Wagons.TypeCatalog[typeName]
    local wagonModel = wagonType and wagonType.models and wagonType.models[model]
    if not wagonModel then
        Core.NotifyRightTip(_U('selectedWagonUnavailable'), 4000)
        return false
    end

    local page = ShopUI.RegisterPage('shop_purchase')
    local currency = tonumber(wagonModel.currency) or 3
    local useCash = currency ~= 2
    local wagonName = ''
    local pending = false

    ShopUI.AddHeader(page, typeName)
    ShopUI.AddText(page, 'wagon_purchase_model', _U('modelLabel', wagonModel.label or model))
    local priceDisplay = ShopUI.AddText(
        page,
        'wagon_purchase_price',
        _U('priceLabel', formatWagonPrice(wagonModel, useCash)),
        currency == 4 and ShopUI.Styles.success or ShopUI.Styles.text
    )

    if currency == 3 then
        page:RegisterElement('arrows', {
            id = 'wagon_purchase_currency',
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
            priceDisplay:update({ value = _U('priceLabel', formatWagonPrice(wagonModel, useCash)) })
        end)
    end

    page:RegisterElement('input', {
        id = 'wagon_purchase_name',
        label = _U('nameWagon'),
        slot = 'content',
        placeholder = _U('namePlaceholder'),
        value = '',
    }, function(input)
        wagonName = input.value or ''
    end)

    ShopUI.AddButton(page, 'wagon_purchase_confirm', _U('purchase'), 'content', function()
        if pending then return end
        local name = ShopUI.Trim(wagonName)
        if name == '' then
            Core.NotifyRightTip(_U('enterName'), 4000)
            return
        end

        pending = true
        Core.Callback.TriggerAsync('bcc-wagons:ProcessWagonPurchase', function(success, result)
            pending = false
            if not success then
                Core.NotifyRightTip(result or _U('purchaseFailed'), 5000)
                return
            end

            FetchRosterAndAction(function()
                ShowSelectedWagonRoster(result, true)
            end)
        end, {
            Model = model,
            Currency = currency,
            IsCash = useCash,
            name = name,
            origin = 'buyWagon',
            siteId = Site,
        })
    end, ShopUI.Styles.success)

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'wagon_purchase_back', _U('backButton'), 'footer', function()
        if pending then return end
        StopRotation()
        ShopUI.OpenPage('shop_models')
    end)
    return true
end
