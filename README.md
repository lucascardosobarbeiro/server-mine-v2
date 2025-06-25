Solution Architecture
The platform is designed with a focus on security, automation, and separation of concerns. The high-level architecture can be visualized as follows:

graph TD
    subgraph "External Environment"
        direction LR
        Player("fa:fa-user Player")
        Admin("fa:fa-user-cog Administrator / DevOps")
    end

    subgraph "Automation Platform"
        direction LR
        GitHub("fa:fa-github-alt GitHub Repository")
        Pipeline("fa:fa-cogs CI/CD Pipeline<br/>(GitHub Actions)")
    end

    subgraph "Google Cloud Platform (GCP)"
        direction TB
        Firewall("fa:fa-shield-alt GCP Firewall")
        IP[("fa:fa-network-wired Static Public IP")]

        subgraph VM["fa:fa-server VM Host (Compute Engine)"]
            subgraph Docker["fa:fa-docker Docker Engine"]
                Proxy[("fa:fa-route<br/>Velocity Proxy<br/>Container")]
                DockerNetwork(fa:fa-sitemap Internal Docker Network)
                GameServers[("fa:fa-gamepad<br/>Game Server Containers<br/>(Lobby, Survival, Creative)")]
            end
        end
        
        Storage(fa:fa-database Cloud Storage<br/>Bucket)
        
    end

    %% Connections
    Admin -- "git push" --> GitHub
    GitHub -- "Triggers" --> Pipeline
    Player -- "Port 25565" --> Firewall
    Firewall --> IP
    IP --> Proxy

    Proxy -- "Communicates via" --> DockerNetwork
    GameServers -- "Communicates via" --> DockerNetwork

    Pipeline -- "SSH via Secure IAP Tunnel" --> VM
    VM -- "Scheduled Backups<br/>(via Cron)" --> Storage

    %% Styles
    style Admin fill:#c9d1d9,color:#1c2128
    style Player fill:#c9d1d9,color:#1c2128
    style VM fill:#DB4437,color:#fff,stroke:#c32a1f,stroke-width:2px
    style Docker fill:#2496ED,color:#fff,stroke:#1d79ba,stroke-width:2px
    style Storage fill:#4285F4,color:#fff,stroke:#2c5da9,stroke-width:2px

How It Works:
User Inputs: The Player connects to the server via the single, publicly exposed port 25565. The Administrator interacts with the system by performing a git push to the repository.

Automation: The git push triggers the CI/CD Pipeline in GitHub Actions.

Secure Connection: The pipeline authenticates with GCP and establishes a secure SSH connection to the VM through a secure IAP Tunnel, keeping the instance isolated from the public internet.

Internal Orchestration: Inside the VM, the Docker Engine manages the containers. Player traffic arrives at the Velocity Proxy, which then routes them to the appropriate Game Servers over a private, internal Docker network.

Data Persistence: The VM itself runs a scheduled cron job to push world data backups to a Cloud Storage Bucket, ensuring data safety.