bind = "0.0.0.0:25565"
online-mode = true
forwarding-secret-file = "/app/forwarding.secret"
[servers]
  try = ["paper"]
  paper = "paper-server:25565"
[advanced]
  player-info-forwarding-mode = "modern"