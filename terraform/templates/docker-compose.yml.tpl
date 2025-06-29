# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
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
      # Montamos um volume dedicado para os dados/configurações do Velocity.
      # A configuração será feita manualmente aqui.
      - velocity-data:/app
    networks:
      - "minecraft-net"
    depends_on:
      - paper

  # --- A CORREÇÃO FINAL ESTÁ AQUI ---
  # O nome do serviço agora é 'paper', exatamente como o pipeline espera.
  paper:
    # IMAGEM OFICIAL E MINIMALISTA DO PAPER
    image: papermc/paper:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      # Montamos um volume dedicado para os dados/configurações do Paper.
      - paper-data:/app
    environment:
      # A imagem 'papermc/paper' usa esta variável para definir a memória.
      MEMORY: "10G"
    networks:
      - "minecraft-net"