local expandedWagonModel

local function canAccessModel(model, job)
    local locks = Wagons.ModelJobLocks and Wagons.ModelJobLocks.Models
    local allowedJobs = locks and locks[model]
    return not allowedJobs or allowedJobs[job] == true
end

local function sortedModels(wagonType)
    local models = {}
    for model, data in pairs(wagonType.models or {}) do
        models[#models + 1] = { model = model, data = data, label = data.label or model }
    end
    table.sort(models, function(left, right) return left.label:lower() < right.label:lower() end)
    return models
end

local function previewShopModel(modelName)
    CreateThread(function()
        ClearShopWagon()
        local requestId = ShopUI.BeginPreviewRequest()
        local model = joaat(modelName)

        Citizen.InvokeNative(0x7F78CD75CC4539E4, CreateVarString(10, 'LITERAL_STRING', _U('loadingShopWagon')))
        if not LoadModel(model, modelName) or not ShopUI.IsPreviewRequestCurrent(requestId) then
            Citizen.InvokeNative(0x58F441B90EA84D06)
            return
        end

        local spawn = ShopUI.GetPreviewWagonConfig()
        if not spawn then
            SetModelAsNoLongerNeeded(model)
            Citizen.InvokeNative(0x58F441B90EA84D06)
            return
        end

        local coords = spawn.coords
        local spawnZ = coords.z - 1.0
        local entity = CreateDraftVehicle(model, coords.x, coords.y, spawnZ, spawn.heading, false, false, true, 0, false)
        SetModelAsNoLongerNeeded(model)
        if not CheckEntityExists(entity) or not ShopUI.IsPreviewRequestCurrent(requestId) then
            if entity and entity ~= 0 and DoesEntityExist(entity) then DeleteEntity(entity) end
            Citizen.InvokeNative(0x58F441B90EA84D06)
            return
        end

        ShopEntity = entity
        ShopUI.HidePreviewWagon(entity)
        ShopUI.PlacePreviewWagon(entity, spawn)
        Citizen.InvokeNative(0x7D9EFB7AD6B19754, entity, true)
        ShopUI.CleanPreviewWagon(entity, function(ready)
            if not ShopUI.IsPreviewRequestCurrent(requestId) then
                if not ShopUI.EntityExists(MyEntity) and not ShopUI.EntityExists(ShopEntity) then
                    Citizen.InvokeNative(0x58F441B90EA84D06)
                end
                return
            end
            if ready then ShopUI.RevealPreviewWagon(entity) end
            Citizen.InvokeNative(0x58F441B90EA84D06)
        end)
        ShopUI.FramePreviewCamera(entity)

        if not Cam then
            Cam = true
            CameraLighting()
        end
    end)
end

local function addModelActions(page, wagonModel, index)
    ShopUI.AddButton(page, 'shop_model_details_' .. index, '    ' .. _U('viewDetails'), 'content', function()
        StopRotation()
        BuildWagonDetailPage({ id = 0, model = wagonModel.model, name = _U('wagonStats') }, 'shop_models')
        ShopUI.OpenPage('wagon_detail')
    end, ShopUI.Styles.text)

    ShopUI.AddButton(page, 'shop_model_purchase_' .. index, '    ' .. _U('purchaseSelection'), 'content', function()
        if BuildShopPurchasePage() then ShopUI.OpenPage('shop_purchase') end
    end, ShopUI.Styles.text)
end

function BuildShopModelsPage()
    local typeName = SelectedTypeName
    local wagonType = typeName and Wagons.TypeCatalog[typeName]
    if not wagonType then
        Core.NotifyRightTip(_U('wagonTypeUnavailable'), 4000)
        return false
    end

    local page = ShopUI.RegisterPage('shop_models')
    local character = LocalPlayer.state.Character or {}
    local job = character.Job or 'unemployed'
    ShopUI.AddHeader(page, typeName)

    for index, wagonModel in ipairs(sortedModels(wagonType)) do
        if canAccessModel(wagonModel.model, job) then
            local expanded = expandedWagonModel == wagonModel.model
            ShopUI.AddButton(
                page,
                'shop_model_' .. index,
                expanded and (wagonModel.label .. ' ▼') or wagonModel.label,
                'content',
                function()
                    StopRotation()
                    expandedWagonModel = expanded and nil or wagonModel.model
                    SelectedModelKey = expandedWagonModel
                    BuildShopModelsPage()
                    ShopUI.OpenPage('shop_models')
                    if expandedWagonModel then previewShopModel(wagonModel.model) else ClearShopWagon() end
                end,
                expanded and ShopUI.Styles.subheader or ShopUI.Styles.button
            )
            if expanded then addModelActions(page, wagonModel, index) end
        end
    end

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'shop_model_rotate', '↻ ' .. _U('rotateButton'), 'footer', function()
        ShopUI.ToggleRotation(-1)
    end)
    ShopUI.AddButton(page, 'shop_model_back', _U('backButton'), 'footer', function()
        StopRotation()
        ClearShopWagon()
        expandedWagonModel = nil
        SelectedModelKey = nil
        BuildShopPage()
        ShopUI.OpenPage('shop')
    end)
    return true
end
