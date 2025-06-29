# A linha 'version' foi removida para seguir as práticas modernas.
networks:
  minecraft-net:
    driver: bridge

services:
  # Usamos a imagem itzg/bungeecord, conforme o exemplo oficial.
  proxy:
    image: itzg/bungeecord
    container_name: bungeecord-proxy
    restart: unless-stopped
    ports:
      # Expõe a porta do proxy para o mundo exterior.
      - "25565:25565"
    environment:
      # --- CONFIGURAÇÃO ASSERTIVA VIA VARIÁVEIS DE AMBIENTE (SEGUINDO A DOC) ---
      # Habilita o modo BungeeCord.
      BUNGEE_ONLINE_MODE: "true"
      # A CHAVE: Diz ao BungeeCord para encontrar o servidor de jogo usando seu nome de serviço.
      # O formato é "nome_no_bungee,endereço_docker,motd,restricted".
      SERVERS: "sobrevivencia,mc-sobrevivencia:25565,Seu Servidor,false"
      # Define o servidor padrão para os jogadores.
      DEFAULT_SERVER: "sobrevivencia"
      # Força o servidor padrão ao entrar.
      FORCE_DEFAULT_SERVER: "true"
      # Define o nome do host do proxy.
      HOST_NAME: "sobrevivencia"

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
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      # O servidor Paper DEVE estar em modo offline para delegar a autenticação ao proxy.
      ONLINE_MODE: "false"
      # Habilita o modo de encaminhamento BungeeCord no backend.
      BUNGEECORD: "TRUE"
    networks:
      - "minecraft-net"