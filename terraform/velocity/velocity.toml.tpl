config-version = "2.7"
bind = "0.0.0.0:25577"
player-info-forwarding-mode = "modern"
forwarding-secret-file = "/config/forwarding.secret"
online-mode = true

[servers]
survivencia = "mc-sobrevivencia:25565"
lobby       = "mc-sobrevivencia:25565"
minigames   = "mc-sobrevivencia:25565"
factions    = "mc-sobrevivencia:25565"

fallback-server = "survivencia"

[forced-hosts]
"lobby.example.com"      = ["lobby"]
"factions.example.com"   = ["factions"]
"minigames.example.com"  = ["minigames"]

[advanced]
compression-threshold = 256
login-ratelimit = 3000
connection-timeout = 5000
read-timeout = 30000

[query]
enabled = true
port = 25577
