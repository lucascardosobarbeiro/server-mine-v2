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
    # Montamos a nossa pasta de config local diretamente para /velocity no contêiner.
    # Isto coloca velocity.toml e forwarding.secret no local que a imagem espera.
    volumes:
      - ./config:/velocity
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