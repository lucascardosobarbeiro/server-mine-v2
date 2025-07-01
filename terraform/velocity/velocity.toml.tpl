bind = "0.0.0.0:25577"
motd = "Servidor Proxy Minecraft"
show-max-players = 100

player-info-forwarding-mode = "modern"
online-mode = true

[servers]
survivencia = "mc-sobrevivencia:25565"
try = ["survivencia"]

[advanced]
forwarding-secret-file = "/config/forwarding.secret"
