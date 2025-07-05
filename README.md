<p align="center">
  <img src="https://res.cloudinary.com/zenbusiness/image/upload/v1670445040/logaster/logaster-2020-06-image14-3.png" width="150" alt="Project Logo" />
</p>
<p align="center">
  <img src="https://img.shields.io/badge/status-complete-green?style=for-the-badge" alt="Complete" />
  <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="MIT" />
</p>
<p align="center">
  <img src="https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="GCP" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />

</p>

**Can see more here > https://lucascardosobarbeiro.github.io/server-mine-v2/**

Automated minecraft server + GCP + Docker compose + Actions + CI/CD + IAC

This project provides a **robust, scalable, and easily editable** Infrastructure as Code (IaC) solution for deploying a production-ready PaperMC Minecraft server with a Velocity proxy on the Google Cloud Platform (GCP). It automates the entire lifecycle, from provisioning and configuration to deployment and updates, all designed to be seamlessly managed through CI/CD pipelines.

The core principle of this architecture is to allow for easy modifications and scaling without needing to manually rebuild server components, making it perfect for pipeline-driven automation.

## ✨ Features

* **Automated Deployment:** Use Terraform to provision and manage the entire infrastructure on GCP.
* **CI/CD with GitHub Actions:** A complete CI/CD pipeline to automate deployments and updates.
* **Containerized Environment:** The Minecraft server and proxy run in Docker containers for a consistent and isolated setup.
* **Production-Ready:** Configured with security and performance best practices in mind.
* **Highly Configurable:** Easily customize server and proxy settings through template files.
* **Automated Backups:** Leverage Google Cloud Storage for automatic backups of your Minecraft world, with lifecycle policies to manage costs.

## 🚀 Technology Stack

* **Cloud Provider:** Google Cloud Platform (GCP)
* **IaC & Configuration Management:** Terraform
* **CI/CD:** GitHub Actions
* **Container Runtime:** Docker Engine & Docker Compose
* **Minecraft Proxy:** Velocity 3.x
* **Minecraft Server:** PaperMC
* **Secrets Management:** GitHub Secrets & Environment Variables
* **Networking:** VPC, Subnets, and Firewall Rules
* **Authentication:** Workload Identity Federation & IAP SSH
* **Storage:** Google Cloud Storage (GCS) for Terraform state and backups
* **Monitoring & Logging:** Cloud Monitoring & Cloud Logging

## 🏛️ Architecture Details

This architecture is designed for automation and scalability, divided into three main layers: **Infrastructure (GCP & Terraform)**, **Application (Docker)**, and **CI/CD (GitHub Actions)**.



### 1. Infrastructure Layer (Provisioning with Terraform on GCP)

This is the project's foundation. Terraform declaratively defines and provisions all necessary GCP resources.

* **Networking (VPC):** A dedicated Virtual Private Cloud isolates the server environment, enhancing security. Firewall rules are configured to only allow necessary traffic (port `25565` for Velocity and `22` for SSH via IAP).
* **Compute (Compute Engine):** A single VM instance is provisioned to run the Docker containers. A startup script handles the initial setup of Docker and Docker Compose.
* **Storage (Google Cloud Storage):** Two GCS buckets are created: one for the remote Terraform state (`tfstate`) and another for world backups, which includes a lifecycle policy to delete old backups and reduce costs.
* **Security & Identity (IAM):** A dedicated Service Account with minimal permissions is created for the VM. **Workload Identity Federation** allows the GitHub Actions pipeline to securely authenticate with GCP without long-lived keys. SSH access is secured via **IAP (Identity-Aware Proxy)**, which uses IAM for authentication instead of traditional SSH keys.

### 2. Application Layer (Containerization with Docker)

The Minecraft server itself is managed by Docker, ensuring a portable and consistent runtime.

* **`docker-compose.yml`:** This file orchestrates the services. The Terraform pipeline syncs this file to the VM.
* **`papermc` service:** Runs the [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) image. It uses a volume mount (`./paper/plugins:/data/plugins`) to map the plugins downloaded by the CI/CD pipeline directly into the container.
* **`velocity` service:** Runs the [itzg/docker-mc-proxy](https://github.com/itzg/docker-mc-proxy) image. It exposes the server to the internet and uses a volume mount (`./velocity/plugins:/config/plugins`) for its own plugins.

### 3. CI/CD & Automation Layer (GitHub Actions)

This layer connects the code repository to the cloud infrastructure, enabling full automation.

* **`.github/workflows/deploy.yml`:** This pipeline-centric approach ensures that any change, from a simple plugin addition to an infrastructure modification, is deployed automatically and consistently.
* **Plugin Fetching:** The first step runs the `scripts/fetch-plugins.sh` script, which reads `manifest.json` and downloads the specified plugins.
* **Secure Authentication:** The pipeline authenticates to GCP using Workload Identity Federation.
* **Infrastructure Deployment:** Finally, `terraform apply` is executed. Terraform updates the GCP resources and syncs all necessary files, including the `docker-compose.yml` and the newly downloaded plugins, to the VM.

## 📁 Project Structure

```bash
.
├── .github/workflows/
│   └── deploy.yml
├── paper/
│   ├── configs/
│   └── plugins/  # PaperMC plugins are downloaded here
├── scripts/
│   └── fetch-plugins.sh # Script that downloads plugins
├── terraform/
│   ├── bootstrap/      # stack with state bucket and Workload Identity
│   ├── ... (terraform .tf files for the main stack)
├── velocity/
│   ├── plugins/  # Velocity plugins are downloaded here
│   └── ... (config files)
├── docker-compose.yml
├── manifest.json       # List of plugins to be downloaded
├── terraform.tfvars.example
└── README.md
```

### Bootstrap stack

Long‑lived resources such as the remote Terraform state bucket and the Workload Identity configuration are defined under `terraform/bootstrap`. Run this stack once before provisioning the rest of the infrastructure:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

The pipelines reference the bucket and service account created in this step, so a normal `terraform destroy` in the main stack will not remove them. After the bootstrap completes, run Terraform in the repository root:

```bash
cd ..
terraform init
terraform apply
```



## 🤝 Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request.

## 📞 Contact

* **Email:** lcb.barbeiro@gmail.com
* **LinkedIn:** [https://www.linkedin.com/in/lucascardosobarbeiro/?locale=en_US](https://www.linkedin.com/in/lucascardosobarbeiro/?locale=en_US)

## 📄 License

This project is licensed under the MIT License.
