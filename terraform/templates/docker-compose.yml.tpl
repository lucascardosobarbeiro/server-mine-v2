networks:
  minecraft-net:
    driver: bridge
services:
  velocity:
    # Usa a nossa imagem customizada.
    image: __GCP_REGION__-docker.pkg.dev/__GCP_PROJECT_ID__/minecraft-repo/velocity-proxy:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    networks:
      - "minecraft-net"
    depends_on:
      - paper
  paper:
    # Usa a nossa imagem customizada.
    image: __GCP_REGION__-docker.pkg.dev/__GCP_PROJECT_ID__/minecraft-repo/paper-server:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      # O volume de dados continua a ser externo para não perder o mundo.
      - paper-data:/app/data
    environment:
      MEMORY: "10G"
    networks:
      - "minecraft-net"
volumes:
  paper-data: