output "workload_identity_provider" {
  description = "The full Workload Identity Provider resource name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.base_project_id
}

# Service Account emails for tfactions
output "terraform_plan_service_account" {
  description = "Service Account email for terraform plan"
  value       = google_service_account.tfactions["terraform-plan"].email
}

output "terraform_apply_service_account" {
  description = "Service Account email for terraform apply"
  value       = google_service_account.tfactions["terraform-apply"].email
}

output "tfmigrate_plan_service_account" {
  description = "Service Account email for tfmigrate plan"
  value       = google_service_account.tfactions["tfmigrate-plan"].email
}

output "tfmigrate_apply_service_account" {
  description = "Service Account email for tfmigrate apply"
  value       = google_service_account.tfactions["tfmigrate-apply"].email
}

# tfactions configuration template
output "tfactions_config_template" {
  description = "Template for tfactions configuration"
  value = <<-EOT
    terraform_plan_config:
      gcp_service_account: ${google_service_account.tfactions["terraform-plan"].email}
      gcp_workload_identity_provider: "${google_iam_workload_identity_pool_provider.github_provider.name}"
    tfmigrate_plan_config:
      gcp_service_account: ${google_service_account.tfactions["tfmigrate-plan"].email}
      gcp_workload_identity_provider: "${google_iam_workload_identity_pool_provider.github_provider.name}"
    terraform_apply_config:
      gcp_service_account: ${google_service_account.tfactions["terraform-apply"].email}
      gcp_workload_identity_provider: "${google_iam_workload_identity_pool_provider.github_provider.name}"
    tfmigrate_apply_config:
      gcp_service_account: ${google_service_account.tfactions["tfmigrate-apply"].email}
      gcp_workload_identity_provider: "${google_iam_workload_identity_pool_provider.github_provider.name}"
  EOT
}
