# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
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
      # Esta variável única configura corretamente o Paper para o proxy.
      BUNGEECORD: "TRUE"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
      
    # --- A CORREÇÃO FINAL E ASSERTIVA ---
    # Substituímos o healthcheck por um que verifica diretamente a porta 25565,
    # um método universal e à prova de falhas.
    healthcheck:
      # O 'nc' (netcat) tenta conectar-se a localhost na porta 25565.
      # Se conseguir, retorna sucesso (código 0), e o serviço é considerado saudável.
      test: ["CMD", "nc", "-z", "localhost", "25565"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

# A seção 'secrets' global para o forwarding.secret.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret