# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

volumes:
  paper-data:

services:
  velocity:
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      # Montamos cada ficheiro individualmente para garantir que estejam no local correto.
      - ./config/velocity.toml:/velocity/velocity.toml
      - ./config/forwarding.secret:/velocity/forwarding.secret
    
    # --- A CORREÇÃO FINAL BASEADA NA ISSUE #1347 ---
    # Tomamos controlo do comando para adicionar o argumento '--velocity-config'.
    # Isto FORÇA o Velocity a ler o nosso ficheiro de configuração.
    working_dir: /velocity
    command: >
      java -jar velocity.jar --velocity-config /velocity/velocity.toml

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
      MEMORY: "10G"
    networks:
      - "minecraft-net"
    healthcheck:
      # A verificação de saúde correta para a imagem oficial do Paper.
      test: ["CMD", "mc-health"]
      interval: 10s
      timeout: 5s
      retries: 5