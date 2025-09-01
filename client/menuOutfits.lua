local Core = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()
---@type BCCWagonsDebugLib
local DBG = BCCWagonsDebug or {
    Info = function() end,
    Error = function() end,
    Warning = function() end,
    Success = function() end
}

local originalOutfit = {}
local CharacterOutfits = {}
local Cam


BCCwagonsOutfitsMenu = FeatherMenu:RegisterMenu("bcc-wagons:outfits:mainmenu",
    {
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
            FreezeEntityPosition(PlayerPedId(), true)
            TaskStandStill(PlayerPedId(), -1)
            if not DoesCamExist(Cam) then
                Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                AttachCamToEntity(Cam, PlayerPedId(), 0.20, 1.50, 0.20, true)
                SetCamRot(Cam, -10.0, 0.0, GetEntityHeading(PlayerPedId()) - 180)
                RenderScriptCams(true, true, 1000, 1, 0)
            end
        end,
        closed = function()
            DisplayRadar(true)
            FreezeEntityPosition(PlayerPedId(), false)
            ClearPedTasks(PlayerPedId())
            if DoesCamExist(Cam) then
                RenderScriptCams(false, true, 1000, 1, 0)
                DestroyCam(Cam, true)
            end
        end
    })

RegisterNetEvent('bcc-wagons:LoadOutfits')
AddEventHandler('bcc-wagons:LoadOutfits', function(CharacterOutfit, result)
    originalOutfit = CharacterOutfit
    CharacterOutfits = result
    OpenOutfitMenu()
end)

function OpenOutfitMenu()
    local MainPage = BCCwagonsOutfitsMenu:RegisterPage('bcc:outfits:menu')
    MainPage:RegisterElement('header', {
        value = _U('wagonOutfits'),
        slot = 'header',
        style = { ['color'] = '#999' }
    })

    MainPage:RegisterElement('subheader', {
        value = _U('OutfitSubMenu'),
        slot = 'header',
        style = { ['font-size'] = '0.94vw', ['color'] = '#CC9900' }
    })

    for i, outfit in pairs(CharacterOutfits) do
        local outfitName = outfit.title and outfit.title ~= "" and outfit.title or "Unnamed Outfit"

        MainPage:RegisterElement('button', {
            label = outfitName,
            slot = 'content',
            style = { ['color'] = '#E0E0E0' }
        }, function()
            OpenOutfitSubMenu(i)
        end)
    end

    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MainPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = { ['color'] = '#E0E0E0' }
    }, function()
        BCCwagonsOutfitsMenu:Close()
    end)

    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    BCCwagonsOutfitsMenu:Open({ startupPage = MainPage })
end

function OpenOutfitSubMenu(index)
    PreviewOutfit(CharacterOutfits[index])
    local SubPage = BCCwagonsOutfitsMenu:RegisterPage('bcc-wagons:outfits:submenu')

    SubPage:RegisterElement('header', {
        value = _U('wagonOutfits'),
        slot = 'header',
        style = { ['color'] = '#999' }
    })

    SubPage:RegisterElement('subheader', {
        value = _U('SelectOutfit'),
        slot = 'header',
        style = { ['font-size'] = '0.94vw', ['color'] = '#CC9900' }
    })

    SubPage:RegisterElement('button', {
        label = _U('SelectOutfit'),
        slot = 'content',
        style = { ['color'] = '#E0E0E0' }
    }, function()
        local Outfit = CharacterOutfits[index]
        local decodedComps = json.decode(Outfit.comps)

        if not decodedComps then
            --print("[Error] Failed to decode Outfit.comps.")
            return
        end

        local result = Core.Callback.TriggerAwait("vorp_character:callback:SetOutfit", { Outfit = Outfit })
        if result then
            local comps = {}
            for k, v in pairs(decodedComps) do
                comps[k] = { comp = v }
            end
            local compTints = Outfit.compTints and json.decode(Outfit.compTints) or {}
            CachedComponents = ConvertTableComps(comps, IndexTintCompsToNumber(compTints))
            BCCwagonsOutfitsMenu:Close()
        else
            --print("[Warning] Failed to set outfit via callback.")
        end        
    end)

    SubPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    SubPage:RegisterElement('button', {
        label = "Back",
        slot = 'footer',
        style = { ['color'] = '#E0E0E0' }
    }, function()
        OpenOutfitMenu()
    end)

    SubPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    BCCwagonsOutfitsMenu:Open({ startupPage = SubPage })
end

function PreviewOutfit(Outfit)
    for i, tag in pairs(HashList) do
        if i ~= 'Hair' and i ~= 'Beard' then
            RemoveTagFromMetaPed(tag, PlayerPedId())
            UpdatePedVariation()
        end
    end

    local comps = json.decode(Outfit.comps) or {}
    local compTints = Outfit.compTints and json.decode(Outfit.compTints) or {}

    compTints = IndexTintCompsToNumber(compTints)

    for key, value in pairs(comps) do
        if type(value) ~= "number" then
            --print(string.format("[Warning] Unexpected data structure in `comps` for key: %s - Skipping entry.", key))
            comps[key] = nil  -- Remove or skip invalid entries
        end
    end

    local convertedComps = ConvertTableComps(comps, compTints)
    LoadComps(convertedComps)
end

function LoadComps(components, set)
    for category, value in pairs(components) do
        if value.comp ~= -1 then
            local status = not set and "false" or GetResourceKvpString(tostring(value.comp))
            if status == "true" then
                RemoveTagFromMetaPed(HashList[category], PlayerPedId())
            else
                ApplyShopItemToPed(value.comp, PlayerPedId())
                if category ~= "Boots" then
                    UpdateShopItemWearableState(PlayerPedId(), `base`)
                end
                Citizen.InvokeNative(0xAAB86462966168CE, PlayerPedId(), 1)
                UpdatePedVariation()
                IsPedReadyToRender()
                if value.tint0 ~= 0 or value.tint1 ~= 0 or value.tint2 ~= 0 or value.palette ~= 0 then
                    local TagData = GetMetaPedData(category == "Boots" and "boots" or category, PlayerPedId())
                    if TagData then
                        local palette = (value.palette ~= 0) and value.palette or TagData.palette
                        SetMetaPedTag(PlayerPedId(), TagData.drawable, TagData.albedo, TagData.normal, TagData.material,
                            palette, value.tint0, value.tint1, value.tint2)
                        UpdatePedVariation(PlayerPedId())
                    end
                end
            end
        end
    end
end

function IndexTintCompsToNumber(table)
    local NewComps = {}

    for i, v in pairs(table) do
        NewComps[i] = {}
        for k, x in pairs(v) do
            NewComps[i][tonumber(k)] = x
        end
    end

    return NewComps
end

function ConvertTableComps(comps, compTints)
    local NewComps = {}

    --print("[Debug] Starting conversion of `comps`:")
    --print(json.encode(comps))

    for k, v in pairs(comps) do
        -- Check if `v` is a number (component hash or -1)
        if type(v) == "number" then
            -- Skip if the component value is -1 (indicating "no component")
            if v ~= -1 then
                NewComps[k] = { comp = v, tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }
                
                -- Apply tints if available in `compTints`
                if compTints and compTints[k] and compTints[k][v] then
                    local compTint = compTints[k][v]
                    NewComps[k].tint0 = compTint.tint0 or 0
                    NewComps[k].tint1 = compTint.tint1 or 0
                    NewComps[k].tint2 = compTint.tint2 or 0
                    NewComps[k].palette = compTint.palette or 0
                end
            else
                --print(string.format("[Debug] Skipping component %s with value -1 (no component)", k))
            end
        else
            --print(string.format("[Warning] Unexpected data structure in `comps` for key: %s - Skipping entry.", tostring(k)))
        end
    end

    --print("[Debug] Finished conversion of `comps`.")
    return NewComps
end

HashList = {
    Gunbelt     = 0x9B2C8B89,
    Mask        = 0x7505EF42,
    Holster     = 0xB6B6122D,
    Loadouts    = 0x83887E88,
    Coat        = 0xE06D30CE,
    Cloak       = 0x3C1A74CD,
    EyeWear     = 0x5E47CA6,
    Bracelet    = 0x7BC10759,
    Skirt       = 0xA0E3AB7F,
    Poncho      = 0xAF14310B,
    Spats       = 0x514ADCEA,
    NeckTies    = 0x7A96FACA,
    Spurs       = 0x18729F39,
    Pant        = 0x1D4C528A,
    Suspender   = 0x877A2CF7,
    Glove       = 0xEABE0032,
    Satchels    = 0x94504D26,
    GunbeltAccs = 0xF1542D11,
    CoatClosed  = 0x662AC34,
    Buckle      = 0xFAE9107F,
    RingRh      = 0x7A6BBD0B,
    Belt        = 0xA6D134C6,
    Accessories = 0x79D7DF96,
    Shirt       = 0x2026C46D,
    Gauntlets   = 0x91CE9B20,
    Chap        = 0x3107499B,
    NeckWear    = 0x5FC29285,
    Boots       = 0x777EC6EF,
    Vest        = 0x485EE834,
    RingLh      = 0xF16A1D23,
    Hat         = 0x9925C067,
    Dress       = 0xA2926F9B,
    Badge       = 0x3F7F3587,
    armor       = 0x72E6EF74,
    Hair        = 0x864B03AE,
    Beard       = 0xF8016BCA,
    bow         = 0x8E84A2AA,
}
