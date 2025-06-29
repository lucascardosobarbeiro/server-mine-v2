# Configuração do BungeeCord gerada para o seu servidor.
listeners:
- query_port: 25577
  motd: '&1Um Servidor Minecraft'
  tab_list: GLOBAL_PING
  query_enabled: false
  proxy_protocol: false
  forced_hosts:
    "__SERVER_IP__:25565": sobrevivencia
  ping_passthrough: false
  priorities:
  - sobrevivencia
  bind_local_address: true
  host: 0.0.0.0:25565 # Força a escutar na porta correta.
  max_players: 100
  tab_size: 60
  force_default_server: true
remote_ping_cache: -1
network_compression_threshold: 256
permissions: {}
log_pings: true
connection_throttle_limit: 3
server_connect_timeout: 5000
timeout: 30000
player_limit: -1
ip_forward: true # Habilita o encaminhamento de IP, essencial para o modo online.
remote_ping_timeout: 5000
connection_throttle: 4000
log_commands: false
prevent_proxy_connections: false
online_mode: true
disabled_commands:
- disabledcommandhere
servers:
  # Define o seu servidor de jogo.
  sobrevivencia:
    motd: '&1Servidor de Sobrevivencia'
    address: mc-sobrevivencia:25565 # Usa o nome do serviço Docker.
    restricted: false