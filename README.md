🚀 OverviewThis project is a comprehensive case study in modern Cloud Engineering and DevOps, demonstrating the end-to-end creation of a robust, secure, and fully automated multi-world Minecraft server platform on Google Cloud Platform (GCP).The goal transcends simply hosting a game server; it serves as a robust portfolio piece that applies industry-standard practices. The entire infrastructure is managed as code (IaC), and the application's lifecycle is automated by a complete CI/CD pipeline, ensuring the system is not only functional but also resilient, manageable, and professional.✨ Key FeaturesInfrastructure as Code (IaC): 100% of the cloud environment (VPC, Firewall, VM, IAM, Storage) is declaratively managed with Terraform, ensuring reproducibility and version control.Full CI/CD Automation: A GitHub Actions workflow automatically deploys application updates upon a git push to the main branch, eliminating manual intervention and human error.Multi-Layered Security:Zero Trust Access: Administrative SSH access is handled exclusively through Google's Identity-Aware Proxy (IAP), keeping port 22 completely closed to the internet.Network Isolation: Services run in a custom VPC with granular firewall rules that only expose the proxy.Principle of Least Privilege: A dedicated GCP Service Account with the bare minimum IAM roles required for operation.Containerized Architecture: All services (Velocity Proxy, PaperMC servers) run in isolated Docker containers, orchestrated on the VM by Docker Compose.Resilience & Professional Operations:Automated Backups: A cron job on the host VM performs daily backups of server worlds to Google Cloud Storage.Proxy & High Availability: A Velocity proxy acts as a single, secure entry point, allowing players to seamlessly switch between game servers and protecting backend servers from direct access.Centralized State Management: Terraform's state is managed by a Remote Backend on GCS, enabling collaborative and safe infrastructure management.🏗️ ArchitectureThe platform is designed with a focus on security, automation, and separation of concerns. The high-level architecture can be visualized as follows:graph TD
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
How It WorksUser Inputs: The Player connects to the server via the single, publicly exposed port 25565. The Administrator interacts with the system by performing a git push to the repository.Automation: The git push triggers the CI/CD Pipeline in GitHub Actions.Secure Connection: The pipeline authenticates with GCP and establishes a secure SSH connection to the VM through a secure IAP Tunnel, keeping the instance isolated from the public internet.Internal Orchestration: Inside the VM, the Docker Engine manages the containers. Player traffic arrives at the Velocity Proxy, which then routes them to the appropriate Game Servers over a private, internal Docker network.Data Persistence: The VM itself runs a scheduled cron job to push world data backups to a Cloud Storage Bucket, ensuring data safety.🛠️ Technology StackTechnologyPurposeGoogle Cloud PlatformCloud ProviderTerraformInfrastructure as CodeDocker & Docker ComposeContainerization & OrchestrationGitHub ActionsCI/CD & AutomationVelocityMinecraft ProxyPaperMCMinecraft Server SoftwareBash & CronAutomation Scripts & Scheduling⚙️ Getting StartedTo deploy this project, you will need to have the following tools installed and configured.PrerequisitesA Google Cloud Platform account with billing enabled.Terraform CLI (v1.0.0+).Google Cloud SDK (gcloud) authenticated with your account (gcloud auth login).A GitHub repository to host the project code.InstallationClone the Repositorygit clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
Configure Terraform VariablesCreate a file named terraform.tfvars by copying the example file.cp terraform.tfvars.example terraform.tfvars
Now, edit terraform.tfvars and fill in your specific project details (GCP Project ID, email, etc.).Deploy the InfrastructureRun the following commands from the project's root directory:# Initialize the Terraform providers
terraform init

# (Optional) Review the execution plan
terraform plan

# Apply the configuration to create the infrastructure in GCP
terraform apply -auto-approve
After the apply is complete, Terraform will output the server's public IP and other important values.Set Up GitHub SecretsThe terraform apply command will output the values for workload_identity_provider and service_account_email_for_github.In your GitHub repository, navigate to Settings > Secrets and variables > Actions.Create two new repository secrets:GCP_WORKLOAD_IDENTITY_PROVIDER: Paste the value from the Terraform output.GCP_SERVICE_ACCOUNT: Paste the service account email from the Terraform output.The project is now fully deployed, and the CI/CD pipeline is active and ready.🕹️ How to UseFor PlayersServer Address: To connect, use the public IP address in your Minecraft client:[YOUR_SERVER_IP_ADDRESS] (Replace with the IP generated by Terraform).Navigation: Once in the Lobby, use the commands /server sobrevivencia or /server criativo to switch between worlds.For the AdministratorAdministrative Access (SSH): Access to the virtual machine is handled securely following a Zero Trust model. Instead of relying on static SSH keys, IAP authenticates every connection based on the user's identity and IAM permissions.# This is a generic command example. The actual command is generated by Terraform.
gcloud compute ssh [INSTANCE_NAME] --zone [YOUR_ZONE] --project [YOUR_PROJECT_ID] --tunnel-through-iap
This method ensures that port 22 is not open to the internet, protecting the instance from brute-force attacks.