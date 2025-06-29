version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    # Usamos a imagem oficial para máxima compatibilidade e previsibilidade.
    image: papermc/velocity:latest
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      # Montamos cada ficheiro individualmente para garantir que sejam lidos
      # nos seus locais padrão, sem ambiguidade.
      - ./config/velocity.toml:/velocity/velocity.toml
      - ./config/forwarding.secret:/velocity/forwarding.secret
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
      # O servidor Paper DEVE estar em modo offline para delegar a autenticação ao proxy.
      ONLINE_MODE: "false"
      
      # --- CONFIGURAÇÃO ASSERTIVA BASEADA NA DOCUMENTAÇÃO ---
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

secrets:
  velocity_secret:
    file: ./config/forwarding.secret