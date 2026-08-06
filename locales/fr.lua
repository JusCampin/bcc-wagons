Locales.fr_lang = {}
for key, value in pairs(Locales.en_lang) do Locales.fr_lang[key] = value end

local translations = {
    backButton = 'Retour', callPrompt = 'Appeler le chariot actif', cash = 'Argent',
    confirmButton = 'Confirmer', currency = 'Devise', enterName = 'Saisissez un nom pour le chariot.',
    free = 'Gratuit', gold = 'Or', loadingWagon = 'Chargement du chariot...', myWagons = 'Mes chariots',
    nameWagon = 'Nom du chariot', nameYourWagon = 'Nommer votre chariot', needJob = "Vous n'avez pas le métier requis !",
    noWagon = "Vous n'avez pas de chariot actif.", purchase = 'Acheter', renameWagon = 'Renommer',
    returnPrompt = 'Renvoyer le chariot', rotateButton = 'Tourner', sellWagon = 'Vendre',
    shopButton = 'Magasin de chariots', shopPrompt = 'Ouvrir le menu', shortCash = "Vous n'avez pas assez d'argent.",
    shortGold = "Vous n'avez pas assez d'or.", takeOutWagon = 'Sortir le chariot', unknown = 'Inconnu',
    viewDetails = 'Voir les détails', wagonDetails = 'Détails du chariot', wagonMenuPrompt = 'Menu du chariot',
    wagonReturned = 'Votre chariot a été renvoyé.', wagonShop = 'Magasin de chariots'
}
for key, value in pairs(translations) do Locales.fr_lang[key] = value end
