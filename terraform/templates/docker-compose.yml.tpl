# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
networks:
  minecraft-net:
    driver: bridge

services:
  # O serviço do proxy foi completamente removido.

  mc-sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    
    # --- MUDANÇA CRÍTICA ---
    # Expomos a porta do servidor de jogo diretamente para o mundo exterior.
    ports:
      - "25565:25565"

    volumes:
      - ./sobrevivencia-data:/data
      
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      
      # --- MUDANÇA CRÍTICA ---
      # O servidor agora fará sua própria autenticação (modo premium).
      ONLINE_MODE: "true"
      
    networks:
      - "minecraft-net"