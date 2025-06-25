# Automated & Secure Minecraft Server Platform on Google Cloud

![GCP](https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Overview
teste
This project demonstrates the end-to-end creation of a robust, secure, and fully automated multi-world Minecraft server platform on Google Cloud Platform (GCP). The entire infrastructure is managed through code (IaC), and it features a complete CI/CD pipeline powered by GitHub Actions for seamless updates and maintenance.

The goal is not just to host a game server, but to showcase modern Cloud Engineering and DevOps best practices, including containerization, network security, least-privilege IAM, automated backups, and a GitOps-based workflow for application lifecycle management.

---

## Architecture

The platform is designed for security and scalability. The high-level architecture is as follows:
[ Git Push ] ------------> |   GitHub Actions (CI/CD)         | ----+
+----------------------------------+     | (SSH via IAP)
v
+----------+   (Internet)    +-----------------+   +------------------+   +-------------------------------------+
|  Player  | --------------> |   GCP Firewall  |-->|    Static IP     |   |          GCP Compute Engine VM        |
+----------+                 |  (Allow 25565)  |   |                  |   |                                     |
+-----------------+   +------------------+   |   +-------------------------------+   |
|   |        Docker Engine          |   |
|   |                               |   |
|   | [ Velocity Proxy Container ]  |   |
|   |      ^ (Port 25565)           |   |
|   |      |                        |   |
|   | &lt;-----> [Docker Network] &lt;----> |   |
|   |      |                        |   |
|   |      v                        |   |
|   | [ Game Server Containers ]    |   |
|   | (Lobby, Survival, Creative)   |   |
|   +-------------------------------+   |
|                                     |
+--------------------------------+                                      +-------------------------------------+
| Google Cloud Storage           | &lt;------------------------------------------ (Scheduled Backups via Cron)
| (Automated Backups Bucket)     |
+--------------------------------+


---

## Key Features

-   **Infrastructure as Code (IaC):** The entire cloud environment (VPC, Firewall, VM, IAM, Storage) is declaratively managed with **Terraform**, ensuring reproducibility and version control.
-   **Full CI/CD Automation:** A **GitHub Actions** workflow automatically deploys application updates upon a `git push` to the `main` branch, eliminating manual intervention.
-   **High Security Standards:**
    -   **Zero Trust Access:** Administrative SSH access is handled exclusively through **Google's Identity-Aware Proxy (IAP)**, meaning the SSH port is not exposed to the internet.
    -   **Network Isolation:** Services run in a custom VPC with granular firewall rules, exposing only the proxy to the public.
    -   **Least Privilege Principle:** A dedicated GCP Service Account with the bare minimum IAM roles required for operation.
-   **Containerized Architecture:** All services (Velocity Proxy, PaperMC servers) run in isolated **Docker** containers, orchestrated on the VM by **Docker Compose**.
-   **Resilience & Operations:**
    -   **Automated Backups:** A `cron` job on the host VM automatically performs daily backups of server worlds to **Google Cloud Storage**.
    -   **Proxy & High Availability:** A **Velocity** proxy acts as a single, secure entry point, allowing players to seamlessly switch between game servers without disconnecting. Docker's restart policies ensure services automatically recover from crashes.

---

## Technology Stack

-   **Cloud Provider:** Google Cloud Platform (GCP)
-   **Infrastructure as Code:** Terraform
-   **Containerization:** Docker & Docker Compose
-   **CI/CD:** GitHub Actions
-   **Minecraft Services:**
    -   Proxy: Velocity
    -   Server: PaperMC

---

## Setup and Deployment

This project can be deployed by following these steps:

### 1. Prerequisites

-   A Google Cloud Platform account with billing enabled.
-   [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed locally.
-   [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed and authenticated (`gcloud auth login`).
-   A GitHub repository to host the project code.

### 2. Configuration

1.  Clone this repository to your local machine.
2.  Create a file named `terraform.tfvars`.
3.  Populate it with your specific configuration, using `terraform.tfvars.example` as a template.

    ```hcl
    # terraform.tfvars
    project_id      = "your-gcp-project-id"
    region          = "southamerica-east1"
    zone            = "southamerica-east1-a"
    gcp_user_email  = "your-email@gmail.com"
    github_repo     = "your-github-username/your-repo-name"
    ```

### 3. Infrastructure Deployment

Run the following commands from the project's root directory:

```bash
# Initialize the Terraform providers
terraform init

# Review the execution plan
terraform plan

# Apply the configuration to create the infrastructure in GCP
terraform apply -auto-approve
After the apply is complete, Terraform will output the server's public IP and other important values needed for the next step.

4. CI/CD Setup
The terraform apply command will output the values for workload_identity_provider and service_account_email_for_github.

In your GitHub repository, navigate to Settings > Secrets and variables > Actions.
Create two new repository secrets:
GCP_WORKLOAD_IDENTITY_PROVIDER: Paste the value from the Terraform output.
GCP_SERVICE_ACCOUNT: Paste the service account email from the Terraform output.
The project is now fully deployed and the CI/CD pipeline is active.

Project Workflow Explained
Day 1: Provisioning
The terraform apply command handles the entire "Day 1" setup. It builds the network, provisions the VM, and uses a startup script to install Docker, configure the Velocity proxy and docker-compose.yml file, and launch all server containers.

Day 2: Operations and Updates
All subsequent maintenance and updates are handled via the Git-based CI/CD workflow ("Day 2").

A developer makes a change locally (e.g., updating a server setting, changing the deploy.yml workflow).
The change is committed and pushed to the main branch on GitHub.
This push automatically triggers the GitHub Actions workflow.
The workflow authenticates to GCP using the secure, keyless Workload Identity Federation.
It then establishes a secure SSH connection to the VM via the IAP tunnel, without needing interactive confirmation.
Finally, it executes commands on the VM, such as docker-compose pull and docker-compose up, to apply the updates to the running application.