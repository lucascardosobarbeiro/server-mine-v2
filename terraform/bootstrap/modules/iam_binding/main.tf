resource "google_service_account_iam_binding" "this" {
  service_account_id = var.service_account_name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${var.pool_name}/attribute.repository/${var.github_repo}"
  ]

  lifecycle {
    prevent_destroy = true
  }
}
