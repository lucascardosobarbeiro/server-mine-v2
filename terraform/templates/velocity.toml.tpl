# Define em qual endereço e porta o proxy deve escutar.
# Esta é a configuração mais crucial para resolver o erro "Connection refused".
bind = "0.0.0.0:25565"

# ESSENCIAL: Habilita o modo de encaminhamento de jogador moderno e seguro.
# Isto resolve o erro de ser expulso (kick) do servidor.
player-info-forwarding-mode = "modern"

# Aponta para o local do ficheiro de segredo que o Docker irá montar.
# O caminho é relativo ao diretório de trabalho do contêiner.
forwarding-secret-file = "forwarding.secret"

# Define os servidores para os quais o Velocity pode enviar jogadores.
[servers]
  # 'try' define a ordem de tentativa de conexão ao entrar no servidor.
  try = ["sobrevivencia"]
  
  # Mapeia o nome do servidor para o seu endereço na rede Docker interna.
  sobrevivencia = "sobrevivencia:25565"

# Força os jogadores que se conectam através do IP público a irem para o servidor 'sobrevivencia'.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# Desativa a recolha de métricas de telemetria.
[metrics]
  enabled = false