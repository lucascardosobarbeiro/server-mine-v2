# Define em qual endereço e porta o proxy deve escutar.
bind = "0.0.0.0:25565"
# Define o modo de autenticação do proxy.
online-mode = true
# Aponta para o ficheiro de segredo.
forwarding-secret-file = "forwarding.secret"

[servers]
  # O nome 'paper' deve corresponder ao nome do serviço Docker do servidor.
  try = ["paper"]
  paper = "paper-server:25565"

[advanced]
  player-info-forwarding-mode = "modern"