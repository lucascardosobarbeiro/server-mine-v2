# Define os servidores para os quais o Velocity pode enviar jogadores.
[servers]
  try = [
    "sobrevivencia"
  ]
  sobrevivencia = "sobrevivencia:25565"

# Força os jogadores que se conectam através do IP público a irem para o servidor 'sobrevivencia'.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# Configurações avançadas e de segurança.
[advanced]
  player-info-forwarding-mode = "modern"

# Desativa a recolha de métricas.
[metrics]
  enabled = false

# --- MUDANÇA CRUCIAL ---
# Aponta para o local correto do ficheiro de segredo.
[forwarding]
  secret-file = "/velocity/config/forwarding.secret"