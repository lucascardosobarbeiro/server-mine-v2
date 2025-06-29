# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

volumes:
  paper-data:

services:
  velocity:
    # IMAGEM OFICIAL E MINIMALISTA DO VELOCITY
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      # Montamos os nossos ficheiros de configuração diretamente nos locais que a imagem espera.
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
      # Montamos um volume dedicado para os dados do jogo.
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
      retries: 10
      start_period: 60s