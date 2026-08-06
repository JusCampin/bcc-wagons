Locales.ro_lang = {}
for key, value in pairs(Locales.en_lang) do Locales.ro_lang[key] = value end

local translations = {
    backButton = 'Înapoi', callPrompt = 'Cheamă căruța activă', cash = 'Bani', confirmButton = 'Confirmă',
    currency = 'Monedă', enterName = 'Introdu un nume pentru căruță.', free = 'Gratuit', gold = 'Aur',
    loadingWagon = 'Se încarcă căruța...', myWagons = 'Căruțele mele', nameWagon = 'Numele căruței',
    nameYourWagon = 'Numește căruța', needJob = 'Nu ai meseria necesară!',
    noWagon = 'Nu ai o căruță activă.', purchase = 'Cumpără', renameWagon = 'Redenumește',
    returnPrompt = 'Returnează căruța', rotateButton = 'Rotește', sellWagon = 'Vinde',
    shopButton = 'Magazin de căruțe', shopPrompt = 'Deschide meniul', shortCash = 'Nu ai suficienți bani.',
    shortGold = 'Nu ai suficient aur.', takeOutWagon = 'Scoate căruța', unknown = 'Necunoscut',
    viewDetails = 'Vezi detaliile', wagonDetails = 'Detalii căruță', wagonMenuPrompt = 'Meniu căruță',
    wagonReturned = 'Căruța a fost returnată.', wagonShop = 'Magazin de căruțe'
}
for key, value in pairs(translations) do Locales.ro_lang[key] = value end
