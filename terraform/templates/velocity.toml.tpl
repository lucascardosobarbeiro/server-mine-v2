# Define quais servidores o Velocity conhece.
[servers]
  # O 'try' define a ordem dos servidores para os quais os jogadores são enviados ao conectar-se.
  try = ["sobrevivencia"]
  # Mapeia o nome 'sobrevivencia' para o endereço do contêiner Docker.
  sobrevivencia = "sobrevivencia:25565"

# Mapeia o seu IP público para o servidor principal.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# --- CORREÇÃO APLICADA AQUI ---
# Configurações avançadas do proxy.
[advanced]
  # Esta linha é a mais importante. Ela força o Velocity a usar o método
  # moderno e seguro de encaminhamento de informações do jogador.
  player-info-forwarding-mode = "modern"

# Desativa a recolha de métricas.
[metrics]
  enabled = false