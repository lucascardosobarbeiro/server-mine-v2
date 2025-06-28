version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  velocity:
    # --- MUDANÇA CRUCIAL: USANDO A IMAGEM OFICIAL ---
    image: papermc/velocity
    container_name: velocity-proxy
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      # Montamos uma pasta inteira de configuração, que conterá nossos ficheiros.
      # Esta é a abordagem padrão para a imagem oficial.
      - ./config:/velocity/config
    # Nenhuma variável de ambiente é necessária para o Velocity, ele lerá os ficheiros.
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
      # A configuração do Paper para receber a conexão do proxy está correta e permanece.
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
    # A imagem oficial do Velocity espera o segredo neste caminho dentro da pasta de config.
    file: ./config/forwarding.secret