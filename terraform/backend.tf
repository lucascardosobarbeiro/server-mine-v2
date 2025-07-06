terraform {
  # Informa ao Terraform para se preparar para usar o Google Cloud Storage.
  # Os detalhes (nome do bucket) serão injetados pela pipeline.
  backend "gcs" {}
}
