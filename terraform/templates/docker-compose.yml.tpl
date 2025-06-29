# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
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
      # --- CONFIGURAÇÃO ASSERTIVA 100% VIA VARIÁVEIS DE AMBIENTE ---
      TYPE: "VELOCITY"
      VELOCITY_ONLINE_MODE: "true"
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      # A CHAVE: Diz ao Velocity para encontrar o servidor de jogo usando seu nome de serviço.
      VELOCITY_SERVERS: "sobrevivencia=mc-sobrevivencia:25565"
      VELOCITY_TRY_SERVERS: "sobrevivencia"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    # Garante que o servidor Paper esteja pronto antes do proxy tentar se conectar.
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
      # Esta única variável instrui a imagem a configurar TODOS os ficheiros
      # necessários para aceitar uma conexão de proxy.
      BUNGEECORD: "TRUE"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    healthcheck:
      # Verificação de saúde compatível com a imagem itzg.
      test: ["CMD", "mc-monitor", "status", "--host=localhost", "--port=25565"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

# A seção 'secrets' global para o forwarding.secret.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret