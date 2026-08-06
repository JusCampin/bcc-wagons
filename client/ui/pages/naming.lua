local namingSubmissionActive = false

---@param selectedWagonId number|string
---@param beforeOpen fun()|nil
local function showRoster(selectedWagonId, beforeOpen)
    FetchRosterAndAction(function()
        local function openRoster()
            ShowSelectedWagonRoster(selectedWagonId, true)
            namingSubmissionActive = false
        end

        if beforeOpen then beforeOpen() end
        openRoster()
    end, function()
        namingSubmissionActive = false
        Core.NotifyRightTip(_U('rosterRefreshFailed'), 5000)
    end)
end

local function submitPurchase(data, name)
    local request = {}
    for key, value in pairs(data) do request[key] = value end
    request.name = name

    Core.Callback.TriggerAsync('bcc-wagons:ProcessWagonPurchase', function(success, result)
        if success then
            showRoster(result)
        else
            namingSubmissionActive = false
            Core.NotifyRightTip(result or _U('purchaseFailed'), 5000)
        end
    end, request)
end

local function submitRename(data, name)
    local wagonId = tonumber(data.wagonId)
    if not wagonId then
        namingSubmissionActive = false
        Core.NotifyRightTip(_U('renameFailed'), 4000)
        return
    end

    Core.Callback.TriggerAsync('bcc-wagons:RenameWagon', function(success)
        if not success then
            namingSubmissionActive = false
            Core.NotifyRightTip(_U('renameFailed'), 4000)
            return
        end

        showRoster(wagonId, function()
            Core.NotifyRightTip(_U('renamedWagon'), 4000)
        end)
    end, { wagonId = wagonId, newName = name })
end

local NAMING_HANDLERS <const> = {
    buyWagon = submitPurchase,
    updateWagon = submitRename,
}

--- @param data table
function BuildNamingPage(data)
    if type(data) ~= 'table' then return false end
    local handler = NAMING_HANDLERS[data.origin]
    if not handler then
        DBG:Error('Unsupported naming page origin: ' .. tostring(data.origin))
        return false
    end

    local page = ShopUI.RegisterPage('naming')
    local inputValue = data.name or ''
    ShopUI.AddHeader(page, _U('nameYourWagon'))

    page:RegisterElement('input', {
        id = 'wagon_name_input',
        label = _U('nameWagon'),
        slot = 'content',
        placeholder = _U('namePlaceholder'),
        value = inputValue,
    }, function(input)
        inputValue = input.value or ''
    end)

    ShopUI.AddButton(page, 'wagon_name_confirm', _U('confirmButton'), 'content', function()
        if namingSubmissionActive then return end
        local name = ShopUI.Trim(inputValue)
        if name == '' then
            Core.NotifyRightTip(_U('enterName'), 4000)
            return
        end

        namingSubmissionActive = true
        handler(data, name)
    end)

    ShopUI.AddFooter(page)
    ShopUI.AddButton(page, 'wagon_name_back', _U('backButton'), 'footer', function()
        if namingSubmissionActive then return end
        StopRotation()
        BuildMyWagonsPage()
        ShopUI.OpenPage('my_wagons')
    end)
    return true
end

--- @param data table
function OpenNamingPage(data)
    if not BuildNamingPage(data) then return end
    ShopMenu:Open({
        startupPage = ShopPages.naming,
        menuFocus = true,
        cursorFocus = true,
        overrideMenu = true,
        allowKeys = true,
    })
end
