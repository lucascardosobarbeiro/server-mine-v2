config-version = "2.7"
bind = "0.0.0.0:25577"
player-info-forwarding-mode = "modern"
forwarding-secret-file = "/config/forwarding.secret"
online-mode = true

# Defina seus servidores
[servers]
survivencia = "mc-sobrevivencia:25565"

# Ordem de fallback
try = ["survivencia"]

# Se quiser que um domínio leve direto ao servidor:
[forced-hosts]
"yourdomain.com" = ["survivencia"]

# Configura fallback-server corretamente (nome deve existir)
fallback-server = "survivencia"

[advanced]
compression-threshold = 256
login-ratelimit = 3000
connection-timeout = 5000
read-timeout = 30000

[query]
enabled = true
port = 25577
