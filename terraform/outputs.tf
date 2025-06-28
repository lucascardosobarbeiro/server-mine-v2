# =================================================================================
# SAÍDAS (OUTPUTS)
# Exibe informações importantes no terminal após a execução do `terraform apply`.
# =================================================================================

# Exibe o IP público do servidor para que você possa compartilhá-lo com os jogadores.
output "server_ip_address" {
  description = "O endereço de IP público para os jogadores se conectarem."
  value       = google_compute_address.static_ip.address
}

# Exibe o comando exato e seguro para acessar a VM via SSH.
output "ssh_command" {
  description = "Comando para acessar a VM via SSH de forma segura."
  value       = "gcloud compute ssh ${google_compute_instance.minecraft_server_host.name} --zone ${var.zone} --project ${var.project_id} --tunnel-through-iap"
}

# As duas saídas abaixo são usadas para configurar os segredos no GitHub.
output "workload_identity_provider" {
  description = "O nome do provedor Workload Identity para usar nos segredos do GitHub."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email_for_github" {
  description = "O e-mail da conta de serviço para usar nos segredos do GitHub."
  value       = google_service_account.minecraft_vm_sa.email
}