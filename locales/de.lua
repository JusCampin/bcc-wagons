Locales.de_lang = {}
for key, value in pairs(Locales.en_lang) do Locales.de_lang[key] = value end

local translations = {
    backButton = 'Zurück', callPrompt = 'Aktiven Wagen rufen', cash = 'Bargeld', confirmButton = 'Bestätigen',
    currency = 'Währung', enterName = 'Gib einen Wagennamen ein.', free = 'Kostenlos', gold = 'Gold',
    loadingWagon = 'Wagen wird geladen...', myWagons = 'Meine Wagen', nameWagon = 'Wagenname',
    nameYourWagon = 'Wagen benennen', needJob = 'Du hast nicht den benötigten Beruf!',
    noWagon = 'Du hast keinen aktiven Wagen.', purchase = 'Kaufen', renameWagon = 'Umbenennen',
    returnPrompt = 'Wagen zurückbringen', rotateButton = 'Drehen', sellWagon = 'Verkaufen',
    shopButton = 'Wagenhändler', shopPrompt = 'Menü öffnen', shortCash = 'Du hast nicht genug Bargeld.',
    shortGold = 'Du hast nicht genug Gold.', takeOutWagon = 'Wagen herausholen', unknown = 'Unbekannt',
    viewDetails = 'Details anzeigen', wagonDetails = 'Wagendetails', wagonMenuPrompt = 'Wagenmenü',
    wagonReturned = 'Dein Wagen wurde zurückgebracht.', wagonShop = 'Wagenhändler'
}
for key, value in pairs(translations) do Locales.de_lang[key] = value end
