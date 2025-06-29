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
        condition: service_healthy # Adicionada condição de saúde para estabilidade

  paper:
    image: papermc/paper:latest
    container_name: paper-server
    restart: unless-stopped
    volumes:
      - paper-data:/app
      
    # --- CORREÇÃO FINAL E ASSERTIVA ---
    # Usamos a variável de ambiente documentada para alocar memória,
    # em vez de substituir o comando de arranque.
    environment:
      EULA: "true"
      MEMORY: "10G" # Ex: "10G", "2048M"
      
    # --- REMOVIDO ---
    # O 'command' customizado foi removido para deixar a imagem usar o seu padrão.
    
    networks:
      - "minecraft-net"