<p align="center">
  <img src="https://res.cloudinary.com/zenbusiness/image/upload/v1670445040/logaster/logaster-2020-06-image14-3.png" width="150" alt="Project Logo"/>
</p>
<!-- Badges -->
<p align="center">
  <img src="https://img.shields.io/badge/status-complete-green?style=for-the-badge" alt="Project Status: Complete"/>
  <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="License: MIT"/>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="GCP"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
  <img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions"/>
</p>

> A production-ready **Infrastructure-as-Code (IaC)** solution designed to deploy a **PaperMC** Minecraft server behind a **Velocity** proxy on the **Google Cloud Platform (GCP)**. It automates provisioning, configuration, deployment, and updates using **Terraform**, **Docker Compose**, and **GitHub Actions**.

---

## 📜 Table of Contents

1.  [🌟 Introduction](#-introduction)
2.  [✨ Key Features](#-key-features)
3.  [🏗️ Technical Architecture](#️-technical-architecture)
4.  [🛠️ Technology Stack](#️-technology-stack)
5.  [📁 Repository Structure](#-repository-structure)
6.  [✅ Prerequisites](#-prerequisites)
7.  [🚀 Setup & Deployment](#-setup--deployment)
8.  [📝 Configuration Templates](#-configuration-templates)
9.  [🔄 CI/CD Pipeline](#-cicd-pipeline)
10. [🧩 Plugin Management](#-plugin-management)
11. [⚙️ Operational Guidelines](#️-operational-guidelines)
12. [🤝 Contributing](#-contributing)
13. [📄 License](#-license)

---

## 🌟 Introduction

**Server-Mine-v2** provides a scalable and reproducible platform for running multiple Minecraft services with minimal manual effort. All infrastructure, from networking to VM instances, is defined as code, and deployments are fully automated.

**Highlights:**

-   **Velocity Proxy** for secure forwarding and server aggregation.
-   **PaperMC Instances** for optimized performance and plugin support.
-   **Terraform** for infrastructure provisioning and remote state management in a GCS bucket.
-   **GitHub Actions** for continuous integration and deployment.

---

## ✨ Key Features

-   **Infrastructure-as-Code**: Provision VPCs, subnets, firewall rules, Compute Engine instances, IAM roles, and Cloud Storage buckets via Terraform.
-   **Remote State**: Store Terraform state securely in a GCS backend bucket.
-   **GitOps Deploys**: Trigger deployments on commits to the `main` branch, ensuring consistency and auditability.
-   **Template-Driven Config**: Maintain `.template` files for all service configurations and inject environment-specific values at deploy time.
-   **Container Orchestration**: Use Docker Compose to manage the `velocity-proxy` and one or more `paper-server` containers with `restart: unless-stopped`.
-   **Secure Secrets**: Manage forwarding secrets, service account credentials, and plugin URLs via GitHub Secrets.
-   **Dynamic Plugin Loading**: Fetch and update plugins on startup using the Hangar API or direct URLs.
-   **Resilience**: Automatic VM and container restarts minimize downtime.

---

## 🏗️ Technical Architecture

```mermaid
flowchart LR
  subgraph "GitHub"
    A[Repo: IaC + Config Templates]
    B[Actions: CI/CD Pipeline]
  end

  B -->|Terraform Apply| C[GCP Infrastructure]
  B -->|gcloud SCP & SSH| C

  subgraph "Google Cloud Platform"
    C -->|Provisions| D[Debian 11 VM]
    D <--> G[Cloud Storage (Terraform state, Backups)]
    D <--> H[Cloud Monitoring & Logging]
  end

  subgraph "VM Instance"
    D -- Docker Compose --> E[Velocity Proxy]
    D -- Docker Compose --> F[PaperMC Servers]
    E --- F
  end

  style D fill:#f9f9f9,stroke:#333,stroke-width:2px
```

-   **Terraform**: Defines all GCP resources and configures a GCS bucket as the remote state backend.
-   **Compute Engine VM**: Runs Docker Engine and Compose, accessible only via IAP SSH.
-   **GitHub Actions**: Automates `terraform init/plan/apply`, config rendering, file transfer, and container restarts.
-   **Cloud Monitoring**: Tracks VM health, container metrics, and logs for alerting.

---

## 🛠️ Technology Stack

| Layer                      | Technology                                                      |
| -------------------------- | --------------------------------------------------------------- |
| **Cloud Provider** | Google Cloud Platform (GCP)                                     |
| **IaC & Config Management**| Terraform (HCL), Environment Templating (`envsubst`)            |
| **CI/CD** | GitHub Actions                                                  |
| **Container Runtime** | Docker Engine + Docker Compose                                  |
| **Minecraft Proxy** | Velocity 3.x                                                    |
| **Minecraft Server** | PaperMC                                                         |
| **Secrets Management** | GitHub Secrets, Environment Variables                           |
| **Networking** | VPC, Subnets, Firewall Rules                                    |
| **Authentication** | Workload Identity Federation, IAP SSH                           |
| **State & Backups** | GCS Buckets                                                     |
| **Monitoring & Logging** | Cloud Monitoring, Cloud Logging                                 |

---

## 📁 Repository Structure

```bash
server-mine-v2/
├── .github/workflows/
│   └── deploy.yml            # CI/CD pipeline definition
├── terraform/                # Terraform modules & configs
│   ├── backend.tf            # GCS remote state backend
│   ├── network.tf            # VPC, subnet, firewall settings
│   ├── compute.tf            # Compute Engine instance metadata & startup
│   ├── iam.tf                # Service accounts & IAM bindings
│   ├── storage.tf            # GCS bucket for backups & state
│   └── variables.tf          # Input variables and defaults
├── velocity/                 # Velocity proxy configuration templates
│   ├── velocity.toml.template
│   └── forwarding.secret.template
├── paper/configs/            # PaperMC server configuration templates
│   ├── paper-global.yml.template
│   └── server.properties
├── docker-compose.yml.template # Docker Compose template with placeholders
├── terraform.tfvars.example  # Sample Terraform variable file
└── README.md                 # Project documentation
```

---

## ✅ Prerequisites

-   [Git](https://git-scm.com/) v2.30+ installed locally.
-   [Terraform](https://www.terraform.io/downloads.html) v1.0+ with `terraform init` access.
-   [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) latest version.
-   A GitHub repository with Actions enabled.
-   A GCP project where you have the following permissions:
    -   `Compute Admin`
    -   `Service Account User`
    -   `Storage Admin`
    -   `IAM Role Viewer`

---

## 🚀 Setup & Deployment

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/lucascardosobarbeiro/server-mine-v2.git](https://github.com/lucascardosobarbeiro/server-mine-v2.git)
    cd server-mine-v2
    ```

2.  **Configure Terraform:**
    ```sh
    # Copy the example file
    cp terraform.tfvars.example terraform/terraform.tfvars

    # Edit terraform/terraform.tfvars with your GCP_PROJECT_ID, GCP_ZONE, INSTANCE_NAME
    ```

3.  **Add GitHub Secrets** (Repository Settings > Secrets and variables > Actions):
    -   `GCP_PROJECT_ID`
    -   `GCP_ZONE`
    -   `INSTANCE_NAME`
    -   `GCP_WORKLOAD_IDENTITY_PROVIDER`
    -   `GCP_SERVICE_ACCOUNT`
    -   `FORWARDING_SECRET`

4.  **Customize templates (optional):**
    -   `velocity/velocity.toml.template`
    -   `paper/configs/paper-global.yml.template`
    -   `docker-compose.yml.template`

5.  **Push your changes** to the `main` branch to trigger the automated deployment.

---

## 📝 Configuration Templates

We use `envsubst` to render placeholders in `.template` files during deployment.

#### Velocity Proxy (`velocity/velocity.toml.template`)
```toml
bind = "0.0.0.0:25577"
forwarding-secret-file = "${FORWARDING_SECRET_FILE}"
# ... other settings
```

#### PaperMC Server (`paper/configs/paper-global.yml.template`)
```yaml
settings:
  global:
    online-mode: false
  velocity:
    enabled: true
    secret: ${FORWARDING_SECRET}
# ... other settings
```

#### Docker Compose (`docker-compose.yml.template`)
```yaml
version: "3.8"
services:
  velocity-proxy:
    image: papermc/velocity:latest
    environment:
      - FORWARDING_SECRET_FILE=/config/forwarding.secret
  paper-server:
    image: itzg/minecraft-server
    environment:
      - EULA=TRUE
      - TYPE=PAPER
      - MEMORY=4G
      - ONLINE_MODE=false
      - PLUGINS=${PLUGINS}
```

---

## 🔄 CI/CD Pipeline

Defined in `.github/workflows/deploy.yml`:

1.  **Checkout**: Clones the code and Terraform modules.
2.  **Terraform**: Runs `init`, `plan`, and `apply` with remote state.
3.  **GCP Auth**: Authenticates via Workload Identity Federation.
4.  **Install Utilities**: Installs `envsubst`, `curl`, `jq`.
5.  **Render Configs**: Renders the configuration templates.
6.  **Download Plugins (Optional)**: Fetches plugins via the Hangar API.
7.  **File Transfer**: Uploads files to the VM (`gcloud compute scp --recurse`).
8.  **Remote Execution**: Connects to the VM via SSH to move files, set permissions, and run `docker compose up -d`.

This workflow guarantees consistent, repeatable deployments across environments.

---

## 🧩 Plugin Management

Dynamically download plugins using the Hangar API.

```yaml
- name: Fetch plugin URL from Hangar
  run: |
    # Fetch the latest plugin version
    VERSION=$(curl -s -H "User-Agent:server-mine/1.0" \
      [https://hangar.papermc.io/api/v1/projects/$](https://hangar.papermc.io/api/v1/projects/$){{ secrets.PLUGIN_AUTHOR }}/${{ secrets.PLUGIN_SLUG }}/versions \
      | jq -r '.versions[-1]')
    
    # Get the download URL for that version
    URL=$(curl -s -H "User-Agent:server-mine/1.0" \
      [https://hangar.papermc.io/api/v1/projects/$](https://hangar.papermc.io/api/v1/projects/$){{ secrets.PLUGIN_AUTHOR }}/${{ secrets.PLUGIN_SLUG }}/versions/$VERSION/download \
      | jq -r '.url')

    # Export the URL to the GitHub Actions environment
    echo "PLUGINS=$URL" >> $GITHUB_ENV
```

Pass `${{ env.PLUGINS }}` into your `docker-compose.yml.template` to auto-download on container startup.

---

## ⚙️ Operational Guidelines

-   **Backups**: Automate VM disk snapshots and archive the `/data` directory to GCS.
-   **Auto-restart**: Use `restart: unless-stopped` in Docker Compose and enable VM auto-restart.
-   **Monitoring**: Configure Cloud Monitoring dashboards and alerting policies.
-   **Security**: Leverage IAP SSH, apply least-privilege IAM roles, and rotate secrets regularly.

---

## 🤝 Contributing

1.  **Fork** this repository.
2.  Create a feature branch (`git checkout -b feature/your-feature`).
3.  Commit your changes and push.
4.  Open a **Pull Request**.

Please follow existing styles and update documentation and templates where necessary.

---

## 📄 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
