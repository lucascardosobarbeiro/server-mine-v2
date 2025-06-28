# Define os servidores para os quais o Velocity pode enviar jogadores.
[servers]
  # 'try' define a ordem de tentativa de conexão ao entrar no servidor.
  try = [
    "sobrevivencia"
  ]
  # Mapeia o nome do servidor para o seu endereço na rede Docker interna.
  sobrevivencia = "sobrevivencia:25565"

# Força os jogadores que se conectam através do IP público a irem para o servidor 'sobrevivencia'.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# Configurações avançadas e de segurança.
[advanced]
  # ESSENCIAL: Habilita o modo de encaminhamento de jogador moderno.
  # Isto envia o UUID e a skin do jogador de forma segura para o servidor de backend.
  player-info-forwarding-mode = "modern"

# Desativa a recolha de métricas de telemetria.
[metrics]
  enabled = false