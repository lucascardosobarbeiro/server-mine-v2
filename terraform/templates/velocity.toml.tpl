# Define em qual endereço e porta o proxy deve escutar.
bind = "0.0.0.0:25565"

# ESSENCIAL: Habilita o modo de encaminhamento de jogador moderno.
player-info-forwarding-mode = "modern"

# Aponta para o local correto do ficheiro de segredo.
forwarding-secret-file = "forwarding.secret"

# Define os servidores para os quais o Velocity pode enviar jogadores.
[servers]
  try = ["sobrevivencia"]
  sobrevivencia = "sobrevivencia:25565"

# Força os jogadores que se conectam através do IP público a irem para o servidor 'sobrevivencia'.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# Desativa a recolha de métricas.
[metrics]
  enabled = false