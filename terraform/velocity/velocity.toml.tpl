# Versão de configuração, obrigatória
config-version = "1.0"

# Configurações principais
bind = "0.0.0.0:25577"
motd = "Servidor Proxy Minecraft"
show-max-players = 100
online-mode = true
player-info-forwarding-mode = "modern"

# Definição dos servidores backend
[servers]
survivencia = "mc-sobrevivencia:25565"
lobby = "mc-sobrevivencia:25565"
minigames = "mc-sobrevivencia:25565"
factions = "mc-sobrevivencia:25565"

# Ordem de fallback padrão
try = ["survivencia"]

# Hosts forçados por domínio
forced-hosts = {
  "lobby.example.com" = "lobby",
  "minigames.example.com" = "minigames",
  "factions.example.com" = "factions"
}

# Configurações avançadas, incluindo referência ao segredo
[advanced]
forwarding-secret-file = "/config/forwarding.secret"
