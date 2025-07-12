# =================================================================================
# SAÍDAS (OUTPUTS)
# Exibe informações importantes no terminal após a execução do `terraform apply`.
# =================================================================================

# Exibe o IP público do servidor para que você possa compartilhá-lo com os jogadores.
output "server_ip_address" {
  description = "O endereço de IP público para os jogadores se conectarem."
  value       = module.compute.ip_address
}

# Exibe o comando exato e seguro para acessar a VM via SSH.
output "ssh_command" {
  description = "Comando para acessar a VM via SSH de forma segura."
  value       = "gcloud compute ssh ${module.compute.instance_name} --zone ${var.zone} --project ${var.project_id} --tunnel-through-iap"
}

# As duas saídas abaixo são usadas para configurar os segredos no GitHub.

output "workload_identity_provider" {
  value = module.wif.github_wif_provider_name
}

# saída do nome do Workload Identity Pool
output "workload_identity_pool" {
  value       = module.wif.pool_name
  description = "Workload Identity Pool usado pelo GitHub Actions"
}
