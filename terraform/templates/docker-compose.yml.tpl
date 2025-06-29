# A linha 'version' foi removida para seguir as práticas modernas.
networks:
  minecraft-net:
    driver: bridge

services:
  proxy:
    # Usamos a imagem correta, itzg/mc-proxy, conforme a documentação.
    image: itzg/mc-proxy
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      TYPE: "VELOCITY"
      VELOCITY_ONLINE_MODE: "true"
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      VELOCITY_SERVERS: "sobrevivencia=mc-sobrevivencia:25565"
      VELOCITY_TRY_SERVERS: "sobrevivencia"
    secrets:
      - velocity_secret
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
      BUNGEECORD: "TRUE"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    healthcheck:
      test: ["CMD", "mc-monitor", "status", "--host=localhost", "--port=25565"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

# --- CORREÇÃO FINAL E ASSERTIVA ---
# Esta secção de nível superior define o segredo, tornando-o disponível
# para todos os serviços que o referenciam.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret