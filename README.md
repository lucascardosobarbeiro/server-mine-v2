
<div align="center">
  <img src="https://res.cloudinary.com/zenbusiness/image/upload/v1670445040/logaster/logaster-2020-06-image14-3.png" width="150" alt="Minecraft Logo"/>
  <h1>Automated & Secure Minecraft Server Platform on GCP</h1>
  <p>
    A production-grade Minecraft server platform on Google Cloud, fully automated with Terraform, Docker, and a GitOps CI/CD pipeline.
  </p>

  ![Status](https://img.shields.io/badge/status-complete-green?style=for-the-badge)
  ![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

   <p>
    Technologies used in this project
  </p> 

   ![GCP](https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white) 
   ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
   ![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white) 
   ![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

  <p>
    <a href="#-overview">Overview</a> •
    <a href="#-key-features">Key Features</a> •
    <a href="#-architecture">Architecture</a> •
    <a href="#-technology-stack">Tech Stack</a> •
    <a href="#-getting-started">Getting Started</a> •
    <a href="#-how-to-use">How to Use</a>
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

## 🏗️ Architecture

The platform is designed with a focus on security, automation, and separation of concerns. The high-level architecture can be visualized as follows:

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
````

### How It Works

  - **User Inputs:** The **Player** connects to the server via the single, publicly exposed port `25565`. The **Administrator** interacts with the system by performing a `git push` to the repository.
  - **Automation:** The `git push` triggers the **CI/CD Pipeline** in GitHub Actions.
  - **Secure Connection:** The pipeline authenticates with GCP and establishes a secure SSH connection to the **VM** through a **secure IAP Tunnel**, keeping the instance isolated from the public internet.
  - **Internal Orchestration:** Inside the VM, the **Docker Engine** manages the containers. Player traffic arrives at the **Velocity Proxy**, which then routes them to the appropriate **Game Servers** over a private, internal Docker network.
  - **Data Persistence:** The VM itself runs a scheduled `cron` job to push world data backups to a **Cloud Storage Bucket**, ensuring data safety.

-----

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

-----

## ⚙️ Getting Started

To deploy this project, you will need to have the following tools installed and configured.

### Prerequisites

  - A Google Cloud Platform account with billing enabled.
  - [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) (`v1.0.0+`).
  - [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) authenticated with your account (`gcloud auth login`).
  - A GitHub repository to host the project code.

### Installation

1.  **Clone the Repository**

    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```

2.  **Configure Terraform Variables**
    Create a file named `terraform.tfvars` by copying the example file.

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

    Now, edit `terraform.tfvars` and fill in your specific project details (GCP Project ID, email, etc.).

3.  **Deploy the Infrastructure**
    Run the following commands from the project's root directory:

    ```bash
    # Initialize the Terraform providers
    terraform init

    # (Optional) Review the execution plan
    terraform plan

    # Apply the configuration to create the infrastructure in GCP
    terraform apply -auto-approve
    ```

    After the apply is complete, Terraform will output the server's public IP and other important values.

4.  **Set Up GitHub Secrets**
    The `terraform apply` command will output the values for `workload_identity_provider` and `service_account_email_for_github`.

      - In your GitHub repository, navigate to **Settings \> Secrets and variables \> Actions**.
      - Create two new repository secrets:
          - `GCP_WORKLOAD_IDENTITY_PROVIDER`: Paste the value from the Terraform output.
          - `GCP_SERVICE_ACCOUNT`: Paste the service account email from the Terraform output.

The project is now fully deployed, and the CI/CD pipeline is active and ready.

-----

## 🕹️ How to Use

### For Players

  - **Server Address:** To connect, use the public IP address in your Minecraft client:
    `[YOUR_SERVER_IP_ADDRESS]` (Replace with the IP generated by Terraform).
  - **Navigation:** Once in the Lobby, use the commands `/server sobrevivencia` or `/server criativo` to switch between worlds.

### For the Administrator

  - **Administrative Access (SSH):** Access to the virtual machine is handled securely following a Zero Trust model. Instead of relying on static SSH keys, IAP authenticates every connection based on the user's identity and IAM permissions.
  
```
```