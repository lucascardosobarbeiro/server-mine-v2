### 4. terraform/velocity/velocity.toml.tpl (corrigido)

bind = "0.0.0.0:25577"
motd = "Servidor Proxy Minecraft"
show-max-players = 100

player-info-forwarding-mode = "modern"
online-mode = true

[servers]
sobrevivencia = "mc-sobrevivencia:25565"
try = ["sobrevivencia"]

[forced-hosts]
"mc.example.com" = "sobrevivencia"

[advanced]
forwarding-secret-file = "/config/forwarding.secret"