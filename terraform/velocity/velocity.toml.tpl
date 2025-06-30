### 4. terraform/velocity/velocity.toml.tpl (Velocity config com forwarding)

[servers]
  [servers.sobrevivencia]
    address = "mc-sobrevivencia:25565"
    try = ["mc-sobrevivencia"]
    motd = "Servidor Sobrevivência"
    restricted = false

[forced-hosts]
  "" = "sobrevivencia"

[advanced]
  forwarding-secret-file = "/config/forwarding.secret"

[server]
  bind = "0.0.0.0:25577"

[query]
  enabled = true
  port = 25577

[metrics]
  enabled = false

[logging]
  console-format = "[%d{HH:mm:ss}] [%level]: %msg%n"
  level = "INFO"