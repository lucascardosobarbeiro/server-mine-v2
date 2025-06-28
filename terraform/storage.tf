# =================================================================================
# BUCKET DE ARMAZENAMENTO (STORAGE BUCKET)
# Cria um "balde" no Cloud Storage para guardar nossos backups.
# =================================================================================
resource "google_storage_bucket" "minecraft_backups" {
  # O nome de um bucket deve ser único em todo o mundo. Usar o ID do projeto
  # ajuda a garantir essa exclusividade.
  name          = "backup-minecraft-${var.project_id}"
  location      = var.region      # Cria o bucket na mesma região dos outros recursos.
  force_destroy = false           # Proteção contra exclusão acidental via Terraform.
  storage_class = "STANDARD"      # Classe de armazenamento padrão.

  # REGRA DE CICLO DE VIDA: Uma excelente prática de gestão de custos.
  lifecycle_rule {
    action {
      type = "Delete" # A ação é apagar.
    }
    condition {
      age = 30 # A condição é: se o arquivo tiver mais de 30 dias de idade.
    }
  }
}