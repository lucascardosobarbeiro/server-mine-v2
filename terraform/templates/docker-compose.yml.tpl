# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

volumes:
  # Definimos volumes nomeados. O Docker irá gerir estes diretórios para nós.
  paper-data:
  velocity-data:

services:
  velocity:
    # IMAGEM OFICIAL E MINIMALISTA DO VELOCITY
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      # Montamos um volume dedicado para os dados e configurações do Velocity.
      - velocity-data:/app
    networks:
      - "minecraft-net"
    depends_on:
      - paper

  paper:
    # IMAGEM OFICIAL E MINIMALISTA DO PAPER
    image: papermc/paper:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      # Montamos um volume dedicado para os dados e configurações do Paper.
      - paper-data:/app
    environment:
      # A imagem 'papermc/paper' usa esta variável para definir a memória.
      MEMORY: "10G"
    networks:
      - "minecraft-net"