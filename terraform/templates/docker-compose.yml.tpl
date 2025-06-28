version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    image: itzg/bungeecord
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      # --- INÍCIO DA CORREÇÃO ---
      TYPE: "VELOCITY"
      TZ: "America/Sao_Paulo"
      # Define o modo de encaminhamento de jogador através de uma variável de ambiente.
      # Esta é a forma preferida pela imagem itzg.
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "modern"
      # Aponta para o segredo que será montado pelo Docker.
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      # Define o servidor de backend.
      VELOCITY_SERVERS: "sobrevivencia=sobrevivencia:25565"
      # --- FIM DA CORREÇÃO ---
    secrets:
      - velocity_secret
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
      MEMORY: "16G"
      ONLINE_MODE: "false"
      # A configuração do Paper permanece a mesma, pois já está correta.
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

# O segredo é definido no nível superior e usado por ambos os serviços.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret