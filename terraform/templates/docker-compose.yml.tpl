# A linha 'version' foi removida para seguir as práticas modernas.
networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    # Usamos a imagem itzg/mc-proxy, da mesma família do servidor, para máxima compatibilidade.
    image: itzg/mc-proxy
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      # Expõe a porta do proxy para o mundo exterior.
      - "25565:25565"
    environment:
      # --- CONFIGURAÇÃO ASSERTIVA 100% VIA VARIÁVEIS DE AMBIENTE ---
      TYPE: "VELOCITY"
      # Força o modo online, como requisitado pela documentação do Velocity.
      VELOCITY_ONLINE_MODE: "true"
      # Habilita o modo de encaminhamento moderno e seguro.
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      # Aponta para o ficheiro de segredo que o Docker Secrets irá montar.
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      # A CHAVE: Diz ao Velocity para encontrar o servidor de jogo usando seu nome de serviço.
      VELOCITY_SERVERS: "sobrevivencia=mc-sobrevivencia:25565"
      # Define o servidor padrão para onde os jogadores são enviados.
      VELOCITY_TRY_SERVERS: "sobrevivencia"
    secrets:
      - velocity_secret
    networks:
      - "minecraft-net"
    # Garante que o servidor Paper esteja pronto antes do proxy tentar se conectar.
    depends_on:
      mc-sobrevivencia:
        condition: service_healthy

  mc-sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    # A porta do servidor Paper NÃO é mais exposta ao exterior.
    volumes:
      - ./sobrevivencia-data:/data
      - ./config/plugins.txt:/config/plugins.txt
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      # O servidor Paper DEVE estar em modo offline para delegar a autenticação ao proxy.
      ONLINE_MODE: "false"
      PLUGINS_FILE: "/config/plugins.txt"
      
      # --- CONFIGURAÇÃO DO PAPER PARA CONFIAR NO VELOCITY ---
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
    # --- HEALTHCHECK PARA O 'depends_on' ---
    # Permite que o Velocity espere o Paper ficar saudável antes de arrancar.
    healthcheck:
      test: ["CMD", "mc-health"]
      interval: 10s
      timeout: 5s
      retries: 5

# A seção 'secrets' global para o forwarding.secret.
secrets:
  velocity_secret:
    file: ./config/forwarding.secret