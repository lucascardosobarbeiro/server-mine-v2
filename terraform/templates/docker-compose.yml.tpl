# A linha 'version' foi removida para seguir as práticas modernas.
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
      # Montamos um volume dedicado para os dados/configurações do Paper.
      - paper-data:/app
    environment:
      # A única variável necessária é para aceitar o EULA.
      EULA: "true"
    # --- MUDANÇA ASSERTIVA NO ARRANQUE ---
    # Substituímos o comando de arranque padrão para definir a memória.
    command: java -Xms10G -Xmx10G -jar paper.jar --nogui
    networks:
      - "minecraft-net"