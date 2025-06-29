# Define em qual endereço e porta o proxy deve escutar.
bind = "0.0.0.0:25565"

# Define o modo de autenticação do proxy. Essencial para servidores premium.
online-mode = true

# Aponta para o ficheiro de segredo. O caminho é relativo ao diretório de trabalho.
forwarding-secret-file = "forwarding.secret"

[servers]
  # O nome 'paper' deve corresponder ao nome do serviço Docker do servidor.
  try = ["paper"]
  paper = "paper-server:25565"

[advanced]
  # ESSENCIAL: Habilita o modo de encaminhamento de jogador moderno e seguro.
  player-info-forwarding-mode = "modern"