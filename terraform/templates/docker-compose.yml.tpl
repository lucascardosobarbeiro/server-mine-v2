# Conteúdo de: terraform/templates/docker-compose.yml.tpl

version: '3.8'

secrets:
  velocity_secret:
    file: ./config/forwarding.secret

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    image: itzg/bungeecord
    container_name: velocity-proxy
    restart: unless-stopped
    ports: ["25565:25565"]
    volumes:
      - ./config/velocity.toml:/server/velocity.toml
      - ./config/forwarding.secret:/server/forwarding.secret:ro
    environment:
      TYPE: "VELOCITY"
      TZ: "America/Sao_Paulo"
    networks: ["minecraft-net"]

  sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    volumes:
      - ./sobrevivencia-data:/data
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "8G" # Ajustado para o seu custom-4-18432
      ONLINE_MODE: "false"
      # Injeta o segredo no paper-global.yml de forma segura
      YAML_MODS: |
        - file: config/paper-global.yml
          path: proxies.velocity.enabled
          value: true
        - file: config/paper-global.yml
          path: proxies.velocity.online-mode
          value: true
        - file: config/paper-global.yml
          path: proxies.velocity.secret
          value: !!str `cat /run/secrets/velocity_secret`
    secrets:
      - velocity_secret
    networks: ["minecraft-net"]