# Define em qual endereço e porta o proxy deve escutar.
# Garante que o servidor esteja acessível externamente na porta correta.
bind = "0.0.0.0:25565"

# Define o modo de autenticação do proxy. Verdadeiro para servidores premium.
online-mode = true

# Aponta para o ficheiro de segredo. O caminho é relativo ao diretório de trabalho do contêiner.
forwarding-secret-file = "forwarding.secret"

# Define os servidores para os quais o Velocity pode enviar jogadores.
[servers]
  try = ["sobrevivencia"]
  sobrevivencia = "sobrevivencia:25565"

# Força os jogadores que se conectam através do IP público a irem para o servidor 'sobrevivencia'.
[forced-hosts]
  "__SERVER_IP__:25565" = ["sobrevivencia"]

# Configurações avançadas e de segurança.
[advanced]
  # ESSENCIAL: Habilita o modo de encaminhamento de jogador moderno e seguro.
  player-info-forwarding-mode = "modern"