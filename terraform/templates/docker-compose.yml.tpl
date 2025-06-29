# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

volumes:
  paper-data:
  velocity-data:

services:
  velocity:
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      - velocity-data:/app
    networks:
      - "minecraft-net"
    depends_on:
      paper:
        condition: service_healthy

  paper:
    image: papermc/paper:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      - paper-data:/app
    environment:
      EULA: "true"
      MEMORY: "10G"
    networks:
      - "minecraft-net"
      
    # --- CORREÇÃO FINAL E ASSERTIVA ---
    # Adicionamos uma verificação de saúde para que o 'depends_on' funcione.
    # O Docker irá verificar se a porta 25565 está a aceitar conexões dentro do contêiner.
    healthcheck:
      test: ["CMD", "mc-health"]
      interval: 10s
      timeout: 5s
      retries: 5