# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    image: itzg/bungeecord
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      TYPE: "VELOCITY"
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      VELOCITY_SERVERS: "sobrevivencia=mc-sobrevivencia:25565"
      VELOCITY_TRY_SERVERS: "sobrevivencia"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    # --- CORREÇÃO FINAL E ASSERTIVA ---
    # A dependência agora aponta para o nome do serviço correto: 'sobrevivencia'.
    depends_on:
      sobrevivencia:
        condition: service_healthy

  sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    volumes:
      - ./sobrevivencia-data:/data
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      ONLINE_MODE: "false"
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
    networks:
      - "minecraft-net"

secrets:
  velocity_secret:
    file: ./config/forwarding.secret