# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

volumes:
  # Definimos os volumes que irão persistir os dados e configurações.
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
      # Montamos os nossos ficheiros de configuração diretamente no diretório
      # de trabalho do contêiner, forçando o seu uso.
      - ./config/velocity.toml:/velocity/velocity.toml
      - ./config/forwarding.secret:/velocity/forwarding.secret
    networks:
      - "minecraft-net"
    depends_on:
      paper:
        condition: service_healthy

  paper:
    # IMAGEM OFICIAL E MINIMALISTA DO PAPER
    image: papermc/paper:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      - paper-data:/app
    environment:
      # A imagem 'papermc/paper' usa esta variável para definir a memória.
      MEMORY: "10G"
    networks:
      - "minecraft-net"
    healthcheck:
      # Esta imagem vem com uma ferramenta de verificação de saúde.
      test: ["CMD", "mc-health"]
      interval: 10s
      timeout: 5s
      retries: 5