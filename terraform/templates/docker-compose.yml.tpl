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
    # --- INÍCIO DA CORREÇÃO FINAL ---
    # Montamos os nossos próprios ficheiros de configuração diretamente,
    # tomando controlo total sobre a configuração do Velocity.
    volumes:
      - ./config/velocity.toml:/server/velocity.toml
      - ./config/forwarding.secret:/server/forwarding.secret
    # Removemos TODAS as variáveis de ambiente do Velocity para evitar
    # qualquer conflito com os ficheiros que estamos a montar.
    environment:
      TYPE: "VELOCITY"
      TZ: "America/Sao_Paulo"
      # --- FIM DA CORREÇÃO FINAL ---
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