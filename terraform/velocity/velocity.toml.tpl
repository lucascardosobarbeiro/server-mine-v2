[servers]
  [servers.sobrevivencia]
    address = "mc-sobrevivencia:25565"
    motd = "Servidor Paper Minecraft"
    restricted = false

[forced-hosts]
  "127.0.0.1" = "sobrevivencia"

[advanced]
  compression-threshold = 256
  forwarding-secret-file = "/config/forwarding.secret"
  forwarding-mode = "secret"

[metrics]
  enabled = false

[query]
  enabled = true
  port = 25577

[server-ping]
  enabled = true
  hide-addresses = false

[smart-routing]
  enabled = false
