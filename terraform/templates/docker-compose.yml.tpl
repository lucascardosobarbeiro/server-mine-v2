paper:
  image: papermc/paper:latest
  container_name: paper-server
  restart: unless-stopped
  volumes:
    - paper-data:/data
  environment:
    MEMORY: "10G"
    EULA: "TRUE"
  networks:
    - "minecraft-net"
  healthcheck:
    test: ["CMD", "mc-health"]
    interval: 10s
    timeout: 5s
    retries: 10
    start_period: 60s