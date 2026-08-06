--- @param wagon table
--- @param origin 'my_wagons'|'shop_models'|nil
function BuildWagonDetailPage(wagon, origin)
    if type(wagon) ~= 'table' then return end

    local page = ShopUI.RegisterPage('wagon_detail')
    local wagonId = tonumber(wagon.id)
    local wagonName = wagon.name or (wagonId and _U('wagonNumber', wagonId) or _U('wagonDetails'))
    local typeName, modelData = ShopUI.GetModel(wagon.model)
    local modelName = modelData and modelData.label or _U('unknown')
    local inventoryLimit = modelData and tonumber(modelData.invLimit)

    ShopUI.AddHeader(page, wagonName)

    ShopUI.AddText(page, 'wagon_detail_identity', ('%s %s\n%s %s\n%s %s'):format(
        _U('wagonType'), typeName or _U('unknown'),
        _U('wagonModel'), modelName,
        _U('invLimit'), inventoryLimit and tostring(inventoryLimit) or _U('notAvailable')
    ))

    page:RegisterElement('line', { slot = 'content' })

    ShopUI.AddFooter(page)

    ShopUI.AddButton(page, 'wagon_detail_rotate', '↻ ' .. _U('rotateButton'), 'footer', function()
        ShopUI.ToggleRotation(-1)
    end)

    ShopUI.AddButton(page, 'wagon_detail_back', _U('backButton'), 'footer', function()
        StopRotation()
        if origin == 'shop_models' then
            BuildShopModelsPage()
            ShopUI.OpenPage('shop_models')
        else
            BuildMyWagonsPage()
            ShopUI.OpenPage('my_wagons')
        end
    end)
end
