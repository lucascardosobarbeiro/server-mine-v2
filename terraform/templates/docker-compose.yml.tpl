version: '3.8'

networks:
  minecraft-net:
    driver: bridge

services:
  # O serviço do Velocity foi completamente removido.

  sobrevivencia:
    image: itzg/minecraft-server
    container_name: mc-sobrevivencia
    restart: unless-stopped
    
    # --- MUDANÇA CRÍTICA ---
    # Expomos a porta do servidor diretamente para o mundo exterior,
    # já que não há mais um proxy.
    ports:
      - "25565:25565"

    volumes:
      - ./sobrevivencia-data:/data
      
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MEMORY: "10G"
      
      # --- MUDANÇA CRÍTICA ---
      # O servidor agora fará sua própria autenticação.
      ONLINE_MODE: "true"
      
      # --- REMOVIDO ---
      # As configurações de YAML_MODS para o proxy foram removidas.
      
    # --- REMOVIDO ---
    # A secção 'secrets' foi removida, pois não há mais proxy.
    networks:
      - "minecraft-net"

# --- REMOVIDO ---
# A secção 'secrets' global foi removida.