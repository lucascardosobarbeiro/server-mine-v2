resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = "Service Account for Minecraft VM"

  lifecycle {
    prevent_destroy = true
  }
}
