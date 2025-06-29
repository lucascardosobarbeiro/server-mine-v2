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
      # --- CONFIGURAÇÃO ASSERTIVA 100% VIA VARIÁVEIS DE AMBIENTE ---
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
      
      # --- A CORREÇÃO FINAL ---
      # Esta única variável instrui a imagem a configurar TODOS os ficheiros