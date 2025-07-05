# =================================================================================
# VARIÁVEIS DE ENTRADA (INPUT VARIABLES)
# Cada bloco 'variable' define um parâmetro que podemos configurar no arquivo terraform.tfvars.
# =================================================================================

# O ID do seu projeto no GCP, a identificação principal.
variable "project_id" {
  description = "O ID do seu projeto no Google Cloud."
  type        = string
}

# A região geográfica onde a maioria dos recursos será criada.
variable "region" {
  description = "A região GCP para criar os recursos."
  type        = string
}

# A zona específica dentro da região. Uma região tem múltiplas zonas para alta disponibilidade.
variable "zone" {
  description = "A zona GCP para criar a VM."
  type        = string
}

# Seu e-mail, usado para te dar permissão de acesso administrativo à VM.
variable "gcp_user_email" {
  description = "Seu e-mail do Google para acesso administrativo seguro via IAP."
  type        = string
}

# O nome do seu repositório no GitHub, essencial para a configuração do CI/CD.
variable "github_repo" {
  description = "Seu repositório no GitHub no formato 'usuario/repositorio'."
  type        = string
}

# Identificadores para Workload Identity e Service Account criados no bootstrap.
variable "account_id" {
  description = "Service Account ID usado no bootstrap."
  type        = string
  default     = "sa-minecraft-vm"
}

variable "pool_id" {
  description = "Workload Identity Pool ID usado no bootstrap."
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "Workload Identity Provider ID usado no bootstrap."
  type        = string
  default     = "github-provider"
}

# Secret key usada pela aplicação Velocity para encaminhar informações dos jogadores.
variable "velocity_secret" {
  description = "Secret key used to forward player info to backend servers"
  type        = string
  sensitive   = true
}

# Variáveis recebidas do módulo de bootstrap:
# Email da Service Account criada para GitHub Actions.
variable "github_service_account_email" {
  description = "Email da Service Account criada no bootstrap para o GitHub Actions"
  type        = string
}

# Nome do provedor Workload Identity criado no bootstrap, para uso na pipeline.
variable "github_workload_identity_provider" {
  description = "Nome (resource name) do Workload Identity Provider criado no bootstrap"
  type        = string
}
