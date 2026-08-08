fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'BCC Team'
version '1.4.0'

shared_scripts {
    'configs/settings.lua',
    'configs/wainwright.lua',
    'configs/inventory.lua',
    'configs/map.lua',
    'configs/wagon_catalog.lua',
    'configs/shop_locations.lua',
    'locales/init.lua',
    'locales/en.lua',
    'locales/fr.lua',
    'locales/de.lua',
    'locales/nl.lua',
    'locales/ro.lua'
}

client_scripts {
    'client/core/init.lua',
    'client/core/helpers.lua',
    'client/core/preview_instance.lua',
    'client/core/dataview.lua',
    'client/ui/menu.lua',
    'client/ui/pages/*.lua',
    'client/wagon/inventory.lua',
    'client/wagon/features.lua',
    'client/wagon/hunting.lua',
    'client/wagon/spawn.lua',
    'client/wagon/return.lua',
    'client/wagon/interactions.lua',
    --'client/wagon/trade.lua',
    'client/wagon/prompts.lua',
    'client/core/main.lua',
    'client/core/commands.lua',
    --'@vorp_character/client/creator_functions.lua',
    --'client/menuOutfits.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/core/init.lua',
    'server/core/helpers.lua',
    'server/core/preview_instance.lua',
    'server/wagon/delivery.lua',
    'server/core/cooldown.lua',
    'server/wagon/inventory.lua',
    'server/wagon/hunting.lua',
    'server/wagon/interactions.lua',
    'server/wagon/purchase.lua',
    'server/wagon/sale.lua',
    'server/wagon/trade.lua',
    'server/core/main.lua',
}

dependency 'feather-menu'
dependency 'bcc-animal-data'
