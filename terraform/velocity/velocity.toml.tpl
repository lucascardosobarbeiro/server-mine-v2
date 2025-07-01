# Obrigatório para versões recentes do Velocity
config-version = "1.0"

bind = "0.0.0.0:25577"
motd = "Servidor Proxy Minecraft"
show-max-players = 100
online-mode = true
player-info-forwarding-mode = "modern"

[servers]
survivencia = "mc-sobrevivencia:25565"
lobby = "mc-sobrevivencia:25565"
minigames = "mc-sobrevivencia:25565"
factions = "mc-sobrevivencia:25565"

try = [ "survivencia" ]

[forced-hosts]
"lobby.example.com" = [ "lobby" ]
"minigames.example.com" = [ "minigames" ]
"factions.example.com" = [ "factions" ]

[advanced]
forwarding-secret-file = "/config/forwarding.secret"
