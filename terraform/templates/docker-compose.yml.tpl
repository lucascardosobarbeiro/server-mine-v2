# A linha 'version' foi removida para seguir as práticas modernas do Docker Compose.
networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    # Usamos a imagem da mesma família do servidor para máxima compatibilidade.
    image: itzg/bungeecord
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      # Expomos a porta do proxy para o mundo exterior.
      - "25565:25565"
    environment:
      # --- CONFIGURAÇÃO ASSERTIVA VIA VARIÁVEIS DE AMBIENTE ---
      TYPE: "VELOCITY"
      # Habilita o modo de encaminhamento moderno.
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      # Aponta para o segredo que será montado pelo Docker Secrets.
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      # A CHAVE: Diz ao Velocity para encontrar o servidor de jogo usando seu nome de serviço.
      VELOCITY_SERVERS: "sobrevivencia=mc-sobrevivencia:25565"
      # Define o servidor padrão para os jogadores.
      VELOCITY_TRY_SERVERS: "sobrevivencia"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    # Garante que o servidor Paper esteja pronto antes do proxy tentar se conectar.
    depends_on:
      mc-sobrevivencia:
        condition: service_healthy

  sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    # A porta do servidor Paper NÃO é mais exposta ao exterior.
    volumes:
      - ./sobrevivencia-data:/data
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      # Voltamos ao modo offline, pois o proxy fará a autenticação.
      ONLINE_MODE: "false"
      # Reativamos a configuração do proxy no Paper.
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

# A seção 'secrets' global para o forwarding.secret.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret