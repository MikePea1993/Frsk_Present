fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'

author 'Frsk'
description 'Christmas Present System'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/bridge.lua',
    'client/client.lua'
}

server_scripts {
    'server/bridge.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/ChristmasPresent.png',
    'html/assets/EmptyPresent.png',
    'html/assets/ChristmasTag.png'
}
