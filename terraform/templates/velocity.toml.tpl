# Conteúdo de: terraform/templates/velocity.toml.tpl

[servers]
  sobrevivencia = "sobrevivencia:25565"
  try = ["sobrevivencia"]

[forced-hosts]
  # O seu pipeline irá substituir este placeholder pelo IP real.
  "__SERVER_IP__:25565" = ["sobrevivencia"]

[advanced]
  # Habilita o modo de encaminhamento moderno e seguro. Essencial.
  player-info-forwarding-mode = "modern"

[metrics]
  enabled = false