version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    
    # --- A MUDANÇA ASSERTIVA E FINAL ---
    # Montamos cada ficheiro individualmente nos seus locais padrão dentro do contêiner.
    # O diretório de trabalho padrão é /velocity.
    volumes:
      - ./config/velocity.toml:/velocity/velocity.toml
      - ./config/forwarding.secret:/velocity/forwarding.secret
    
    # NÃO definimos 'command' ou 'working_dir', para deixar o script da imagem funcionar.
    
    networks:
      - "minecraft-net"

  sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    volumes:
      - ./sobrevivencia-data:/data
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      ONLINE_MODE: "false"
      # A configuração do Paper está correta e permanece a mesma.
      YAML_MODS: |
        - file: config/paper-global.yml
          path: proxies.velocity.enabled
          value: true
        - file: config/paper-global.yml
          path: proxies.velocity.online-mode
          value: true
        - file: config/paper-global.yml
          path: proxies.velocity.secret
          value: !!str `cat /run/secrets/velocity_secret`
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"

secrets:
  velocity_secret:
    file: ./config/forwarding.secret