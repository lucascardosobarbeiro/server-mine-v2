networks:
  minecraft-net:
    driver: bridge

services:
  proxy:
    image: itzg/bungeecord
    container_name: bungeecord-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    # --- A MUDANÇA ASSERTIVA ---
    # Removemos as variáveis de ambiente e montamos o nosso próprio config.yml.
    volumes:
      - ./config/config.yml:/server/config.yml
    networks:
      - "minecraft-net"
    depends_on:
      mc-sobrevivencia:
        condition: service_healthy

  mc-sobrevivencia:
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
      # Habilita o modo de encaminhamento BungeeCord no backend.
      BUNGEECORD: "TRUE"
    networks:
      - "minecraft-net"