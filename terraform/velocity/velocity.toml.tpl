config-version = "2"

bind = "0.0.0.0:25577"
motd = "§3Servidor Velocity com Paper por trás 😎"
show-max-players = 100
player-info-forwarding-mode = "modern"

forwarding-secret-file = "/config/forwarding.secret"

servers = {
  sobrevivencia = {
    address = "mc-sobrevivencia:25565"
    motd = "§aServidor de Sobrevivência 🌲"
    restricted = false
  }
}

forced-hosts = {
  "localhost:25577" = "sobrevivencia"
}

attempt-connection-order = [
  "sobrevivencia"
]

advanced = {
  compression-threshold = 256
  login-ratelimit = 3000
  connection-timeout = 5000
  read-timeout = 30000
  forwarding-secret-file = "/config/forwarding.secret"
}
