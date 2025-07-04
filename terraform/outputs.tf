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
