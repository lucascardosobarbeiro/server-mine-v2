<div align="center">
  <img src="https://res.cloudinary.com/zenbusiness/image/upload/v1670445040/logaster/logaster-2020-06-image14-3.png" width="150" alt="Project Logo"/>
  <h1>Automated & Secure Minecraft Server Platform on GCP</h1>
  <p>
    A production-grade Minecraft server platform on Google Cloud, fully automated with Terraform, Docker, and a GitOps CI/CD pipeline.
  </p>

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/status-complete-green?style=for-the-badge" alt="Project Status: Complete"/>
    <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="License: MIT"/>
  </p>
  <p>
    <img src="https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="GCP"/>
    <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
    <img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions"/>
  </p>

  <!-- Navigation -->
  <p>
    <a href="#-overview">Overview</a> •
    <a href="#-key-features">Key Features</a> •
    <a href="#-architecture-and-technical-deep-dive">Architecture</a> •
    <a href="#-technology-stack">Tech Stack</a> •
    <a href="#-getting-started">Getting Started</a> •
    <a href="#-project-workflow">Workflow</a>
  </p>
</div>

---

## 🚀 Overview

This project is a comprehensive case study in modern Cloud Engineering and DevOps, demonstrating the end-to-end creation of a robust, secure, and fully automated multi-world Minecraft server platform on Google Cloud Platform (GCP).

The goal transcends simply hosting a game server; it serves as a robust portfolio piece that applies industry-standard practices. The entire infrastructure is managed as code (IaC), and the application's lifecycle is automated by a complete CI/CD pipeline, ensuring the system is not only functional but also resilient, manageable, and professional.

---

## ✨ Key Features

-   **Infrastructure as Code (IaC):** 100% of the cloud environment (VPC, Firewall, VM, IAM, Storage) is declaratively managed with **Terraform**, ensuring reproducibility and version control.
-   **Full CI/CD Automation:** A **GitHub Actions** workflow automatically deploys application updates upon a `git push` to the `main` branch, eliminating manual intervention and human error.
-   **Multi-Layered Security:**
    -   **Zero Trust Access:** Administrative SSH access is handled exclusively through **Google's Identity-Aware Proxy (IAP)**, keeping port 22 completely closed to the internet.
    -   **Network Isolation:** Services run in a custom VPC with granular firewall rules that only expose the proxy.
    -   **Principle of Least Privilege:** A dedicated GCP Service Account with the bare minimum IAM roles required for operation.
-   **Containerized Architecture:** All services (Velocity Proxy, PaperMC servers) run in isolated **Docker** containers, orchestrated on the VM by **Docker Compose**.
-   **Resilience & Professional Operations:**
    -   **Automated Backups:** A `cron` job on the host VM performs daily backups of server worlds to **Google Cloud Storage**.
    -   **Proxy & High Availability:** A **Velocity** proxy acts as a single, secure entry point, allowing players to seamlessly switch between game servers and protecting backend servers from direct access.
    -   **Centralized State Management:** Terraform's state is managed by a **Remote Backend** on GCS, enabling collaborative and safe infrastructure management.

---

## 🏗️ Architecture and Technical Deep Dive

The platform is designed with a focus on security, automation, and separation of concerns. This architecture not only provides a functional Minecraft server but also serves as a template for deploying containerized applications on GCP following modern DevOps principles.

### High-Level Diagram

```text
                               +----------------------------------+
[ Git Push ] ------------> |   GitHub Actions (CI/CD)         | ----+
                               +----------------------------------+     | (SSH via IAP)
                                                                        v
+----------+   (Internet)    +-----------------+   +------------------+   +-------------------------------------+
|  Player  | --------------> |   GCP Firewall  |-->|    Static IP     |   |       Compute Engine VM Host        |
+----------+                 |  (Allow 25565)  |   |                  |   |                                     |
                             +-----------------+   +------------------+   |   +-------------------------------+   |
                                                                        |   |        Docker Engine          |   |
                                                                        |   |                               |   |
                                                                        |   | [ Velocity Proxy Container ]  |   |
                                                                        |   |      ^ (Port 25565)           |   |
                                                                        |   |      |                        |   |
                                                                        |   | <-----> [Docker Network] <----> |   |
                                                                        |   |      |                        |   |
                                                                        |   |      v                        |   |
                                                                        |   | [   Game Server Containers  ] |   |
                                                                        |   | (Lobby, Survival, Creative)   |   |
                                                                        |   +-------------------------------+   |
                                                                        |                                     |
+--------------------------------+                                      +-------------------------------------+
| Google Cloud Storage           | <------------------------------------------ (Scheduled Backups via Cron)
| (Backup Bucket)                |
+--------------------------------+
```

### Component Deep Dive

-   **Terraform (Infrastructure as Code):** All cloud resources are defined declaratively. The project uses a **GCS Remote Backend** to securely store the state file (`.tfstate`), enabling state locking and collaborative work from multiple machines, solving the problem of state desynchronization.

-   **GCP Compute Engine & Debian 11:** The core workload runs on a GCE VM. After a thorough debugging process, **Debian 11** was chosen for its flexibility and robust support for custom installations, in contrast with the security restrictions of Container-Optimized OS. The `startup-script` includes a comprehensive, multi-step process to reliably install the official Docker repositories and `docker-compose`, ensuring a stable environment.

-   **Docker & Docker Compose:** The entire application is containerized. A **Velocity Proxy** and three **PaperMC Server** containers run as isolated services. **Docker Compose** is used within the startup script to define and manage this multi-container application. The `ONLINE_MODE: "FALSE"` and `BUNGEE_CORD: "TRUE"` settings on the backend servers are critical to allow the Velocity proxy to handle player authentication and forwarding.

-   **GCP Networking (VPC & IAP):** Security is paramount.
    -   **Custom VPC:** The VM resides in a custom Virtual Private Cloud, isolating it from other projects.
    -   **Granular Firewall:** Firewall rules are explicit, only allowing public ingress traffic on port `25565` for game traffic and traffic from Google's IAP service for SSH. **Port 22 is not exposed to the internet.**
    -   **Identity-Aware Proxy (IAP):** Administrative access follows a Zero Trust model. IAP authenticates each connection based on the user's Google identity (via IAM), creating a secure tunnel without the need for a VPN or static SSH keys.

-   **GitHub Actions (CI/CD):** "Day 2" operations are fully automated. After a detailed debugging process with Workload Identity Federation, the pipeline was refactored to use a **Service Account Key (JSON)** stored securely in GitHub Secrets. This direct authentication method proved more robust and reliable for this environment. The pipeline uses `gcloud` to connect via the IAP tunnel and execute update commands.

-   **Data Persistence & Backups:** The Minecraft world data is persisted on the host VM's boot disk using Docker volumes. A simple but effective `cron` job runs a shell script to create compressed archives of this data and sync them to a **Google Cloud Storage** bucket, which has versioning enabled for extra safety.

---

## 🛠️ Technology Stack

| Technology | Purpose |
| :--- | :--- |
| **Google Cloud Platform** | Cloud Provider |
| **Terraform** | Infrastructure as Code |
| **Docker & Docker Compose** | Containerization & Orchestration |
| **GitHub Actions** | CI/CD & Automation |
| **Velocity** | Minecraft Proxy |
| **PaperMC** | Minecraft Server Software |
| **Bash & Cron** | Automation Scripts & Scheduling |

---

## ⚙️ Getting Started

To deploy this project, you will need to have the following tools installed and configured.

### Prerequisites

-   A Google Cloud Platform account with billing enabled.
-   [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) (`v1.0.0+`).
-   [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) authenticated with your account (`gcloud auth login`).
-   A GitHub repository to host the project code.

### Installation

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/lucascardosobarbeiro/server-mine-v2.git](https://github.com/lucascardosobarbeiro/server-mine-v2.git)
    cd server-mine-v2
    ```

2.  **Configure Terraform Variables**
    Create a file named `terraform.tfvars` by copying the example file.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Now, edit `terraform.tfvars` and fill in your specific project details (GCP Project ID, admin email, etc.).

3.  **Deploy the Infrastructure**
    Run the following commands from the project's root directory:
    ```bash
    # Initialize the Terraform providers and configure the remote backend
    terraform init

    # Apply the configuration to create the infrastructure in GCP
    terraform apply -auto-approve
    ```
    After completion, Terraform will output the server's public IP.

4.  **Set Up GitHub Secrets**
    -   Generate a Service Account Key (JSON file) for the `sa-minecraft-vm` service account from the GCP Console.
    -   In your GitHub repository, navigate to **Settings > Secrets and variables > Actions**.
    -   Create a new repository secret named `GCP_SA_KEY` and paste the entire content of the downloaded JSON file as its value.

The project is now fully deployed, and the CI/CD pipeline is active.

---

## 🕹️ Project Workflow

### Day 1: Provisioning

The `terraform apply` command handles the entire "Day 1" setup. It builds the network, provisions the VM, and uses a startup script to install Docker, configure the Velocity proxy and `docker-compose.yml`, and launch all containers.

### Day 2: Operations and Updates

All subsequent maintenance is handled via the GitOps workflow:
1.  A developer makes a change locally (e.g., updating a server setting).
2.  The change is committed and pushed to the `main` branch.
3.  The `push` automatically triggers the GitHub Actions workflow.
4.  The pipeline authenticates to GCP using the secure Service Account Key.
5.  It establishes a secure SSH connection to the VM via the IAP tunnel.
6.  Finally, it executes `docker compose` commands to apply the updates to the running application.
