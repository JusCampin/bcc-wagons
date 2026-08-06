local function canAccessModel(model, job)
    local locks = Wagons.ModelJobLocks and Wagons.ModelJobLocks.Models
    local allowedJobs = locks and locks[model]
    return not allowedJobs or allowedJobs[job] == true
end

local function typeHasAccessibleModel(wagonType, job)
    for model in pairs(wagonType.models or {}) do
        if canAccessModel(model, job) then return true end
    end
    return false
end

function BuildShopPage()
    local page = ShopUI.RegisterPage('shop')
    ShopUI.AddHeader(page, _U('wagonShop'))

    if IsPlayerBlockedFromCurrentWainwrightShop() then
        ShopUI.AddText(
            page,
            'shop_access_denied',
            _U('wainwrightBuyWagon'),
            ShopUI.Styles.danger
        )
    else
        local character = LocalPlayer.state.Character or {}
        local job = character.Job or 'unemployed'

        for index, typeName in ipairs(Wagons.TypeOrder or {}) do
            local wagonType = Wagons.TypeCatalog[typeName]
            if wagonType and typeHasAccessibleModel(wagonType, job) then
                ShopUI.AddButton(page, 'shop_type_' .. index, typeName, 'content', function()
                    SelectedTypeName = typeName
                    BuildShopModelsPage()
                    ShopUI.OpenPage('shop_models')
                end)
            end
        end
    end

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'shop_back', _U('backButton'), 'footer', function()
        StopRotation()
        ExpandedWagonId = nil
        BuildMyWagonsPage()
        ShopUI.OpenPage('my_wagons')
    end)
end
