# =================================================================================
# BLOCO DO PROVEDOR (PROVIDER)
# Define que estamos usando o Google Cloud como nosso provedor de nuvem.
# =================================================================================
provider "google" {
  # 'project' e 'region' são herdados do arquivo de variáveis, tornando o código reutilizável.
  project = var.project_id
  region  = var.region
}

# =================================================================================
# BLOCO DE CONFIGURAÇÃO DO TERRAFORM
# Define os provedores necessários para este projeto e suas versões.
# =================================================================================
terraform {
  required_providers {
    # Especifica que precisamos do provedor "google" da HashiCorp.
    # A versão "~> 5.0" significa "use qualquer versão 5.x", o que garante
    # compatibilidade e evita que atualizações automáticas quebrem o código.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    # O provedor "random" é usado para gerar strings aleatórias,
    # garantindo nomes únicos para recursos que exigem isso (como o Workload Identity Pool).
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}