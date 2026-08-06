Locales.nl_lang = {}
for key, value in pairs(Locales.en_lang) do Locales.nl_lang[key] = value end

local translations = {
    backButton = 'Terug', callPrompt = 'Actieve wagen oproepen', cash = 'Contant geld', confirmButton = 'Bevestigen',
    currency = 'Valuta', enterName = 'Voer een wagennaam in.', free = 'Gratis', gold = 'Goud',
    loadingWagon = 'Wagen laden...', myWagons = 'Mijn wagens', nameWagon = 'Wagennaam',
    nameYourWagon = 'Geef je wagen een naam', needJob = 'Je hebt de vereiste baan niet!',
    noWagon = 'Je hebt geen actieve wagen.', purchase = 'Kopen', renameWagon = 'Hernoemen',
    returnPrompt = 'Wagen terugbrengen', rotateButton = 'Draaien', sellWagon = 'Verkopen',
    shopButton = 'Wagenwinkel', shopPrompt = 'Menu openen', shortCash = 'Je hebt niet genoeg geld.',
    shortGold = 'Je hebt niet genoeg goud.', takeOutWagon = 'Wagen buiten zetten', unknown = 'Onbekend',
    viewDetails = 'Details bekijken', wagonDetails = 'Wagendetails', wagonMenuPrompt = 'Wagenmenu',
    wagonReturned = 'Je wagen is teruggebracht.', wagonShop = 'Wagenwinkel'
}
for key, value in pairs(translations) do Locales.nl_lang[key] = value end
