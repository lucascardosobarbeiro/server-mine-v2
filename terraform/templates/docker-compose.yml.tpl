# A linha 'version' é obsoleta e foi removida.
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
      - "25565:25565"
    
    # --- CONFIGURAÇÃO ASSERTIVA 100% VIA VARIÁVEIS DE AMBIENTE ---
    environment:
      # Define o tipo de proxy a ser executado.
      TYPE: "VELOCITY"
      
      # Força o modo online, como requisitado pela documentação do Velocity.
      VELOCITY_ONLINE_MODE: "true"
      
      # Habilita o modo de encaminhamento moderno e seguro.
      VELOCITY_PLAYER_INFO_FORWARDING_MODE: "MODERN"
      
      # Aponta para o ficheiro de segredo que o Docker Secrets irá montar.
      VELOCITY_FORWARDING_SECRET_PATH: "/run/secrets/velocity_secret"
      
      # A CHAVE: Diz ao Velocity para encontrar o servidor de jogo usando seu nome de serviço.
      # O formato é "nome_no_velocity=nome_do_serviço_docker:porta".
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
      # O servidor Paper DEVE estar em modo offline para delegar a autenticação ao proxy.
      ONLINE_MODE: "false"
      
      # --- CONFIGURAÇÃO ASSERTIVA DO PAPER (conforme documentação do itzg e PaperMC) ---
      # Injeta a configuração de proxy diretamente no ficheiro paper-global.yml.
      YAML_MODS: |
        - file: config/paper-global.yml
          path: proxies.velocity.enabled
          value: true
        # Esta linha alinha o estado online do Paper (para o proxy) com o do Velocity.
        - file: config/paper-global.yml
          path: proxies.velocity.online-mode
          value: true
        # Lê o segredo do ficheiro montado pelo Docker Secrets.
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