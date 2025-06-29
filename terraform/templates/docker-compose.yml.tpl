version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    # Voltamos para a imagem itzg, que é altamente configurável via 'env'.
    image: itzg/bungeecord
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    
    # --- A MUDANÇA ASSERTIVA E FINAL ---
    # Configuramos TUDO via variáveis de ambiente. A imagem irá gerar o seu
    # próprio velocity.toml internamente com base nestas instruções.
    environment:
      TYPE: "VELOCITY"
      # Força a porta correta.
      SERVER_PORT: "25565"
      # Define o modo de encaminhamento de jogador.
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      # Aponta para o ficheiro de segredo que vamos montar.
      VELOCITY_FORWARDING_SECRET_PATH: "/server/forwarding.secret"
      # Define o servidor de backend.
      VELOCITY_SERVERS: "sobrevivencia=sobrevivencia:25565"
      # Define o servidor padrão para onde os jogadores são enviados.
      VELOCITY_TRY_SERVERS: "sobrevivencia"

    # Montamos apenas o ficheiro de segredo, sem a flag 'read-only'
    # para evitar o erro de permissão 'chown' que tivemos no início.
    volumes:
      - ./config/forwarding.secret:/server/forwarding.secret

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