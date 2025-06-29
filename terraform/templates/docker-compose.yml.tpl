# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
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
      # --- CONFIGURAÇÃO DO PROXY VELOCITY ---
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
      # O servidor Paper DEVE estar em modo offline para delegar a autenticação.
      ONLINE_MODE: "false"
      
      # --- A CORREÇÃO FINAL E ASSERTIVA ---
      # Esta única variável instrui a imagem a configurar TODOS os ficheiros
      # necessários (spigot.yml, paper-global.yml) para aceitar uma conexão de proxy.
      # Ela substitui o bloco YAML_MODS complexo.
      BUNGEECORD: "TRUE"
      
    secrets:
      # O segredo ainda é necessário para o Velocity, mas a configuração
      # principal é feita pela variável BUNGEECORD.
      - velocity_secret
    networks:
      - "minecraft-net"
    healthcheck:
      test: ["CMD", "mc-health"]
      interval: 10s
      timeout: 5s
      retries: 5

# A seção 'secrets' global para o forwarding.secret.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret