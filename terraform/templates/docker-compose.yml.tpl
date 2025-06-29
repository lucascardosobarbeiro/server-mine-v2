# A linha 'version' foi removida.
networks:
  minecraft-net:
    driver: bridge

services:
  # O serviço 'proxy' foi removido para focar no servidor standalone.

  mc-sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    ports:
      - "25565:25565"
    volumes:
      - ./sobrevivencia-data:/data
      # --- ADIÇÃO PARA PLUGINS ---
      # Montamos o nosso ficheiro de lista de plugins dentro do contêiner.
      - ./config/plugins.txt:/config/plugins.txt
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      ONLINE_MODE: "true"
      # --- ADIÇÃO PARA PLUGINS ---
      # Dizemos ao script de inicialização para ler a nossa lista de plugins.
      PLUGINS_FILE: "/config/plugins.txt"
    networks:
      - "minecraft-net"