version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    # --- CORREÇÃO FINAL E ASSERTIVA ---
    # Montamos cada ficheiro individualmente para garantir que sejam lidos.
    volumes:
      - ./config/velocity.toml:/velocity/velocity.toml
      - ./config/forwarding.secret:/velocity/forwarding.secret
    networks:
      - "minecraft-net"

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