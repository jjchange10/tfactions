# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.base_project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# Workload Identity Provider for GitHub
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.base_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Provider"
  description                        = "Workload Identity Provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository == '${var.github_repository}'"
}

# Service Accounts for tfactions
locals {
  service_accounts = {
    terraform-plan = {
      id           = "terraform-plan"
      display_name = "Terraform Plan Service Account"
      description  = "Service Account for terraform plan operations"
      roles = [
        "roles/viewer",                    # リソースの読み取り
        "roles/storage.objectViewer",      # tfstate読み取り
      ]
    }
    terraform-apply = {
      id           = "terraform-apply"
      display_name = "Terraform Apply Service Account"
      description  = "Service Account for terraform apply operations"
      roles = [
        "roles/editor",                    # リソース作成・更新・削除
        "roles/storage.admin",             # tfstate読み書き
        "roles/iam.serviceAccountAdmin",   # サービスアカウント管理
        "roles/iam.workloadIdentityPoolAdmin", # Workload Identity管理
        "roles/resourcemanager.projectIamAdmin", # IAM権限管理
      ]
    }
    tfmigrate-plan = {
      id           = "tfmigrate-plan"
      display_name = "tfmigrate Plan Service Account"
      description  = "Service Account for tfmigrate plan operations"
      roles = [
        "roles/viewer",                    # リソースの読み取り
        "roles/storage.objectViewer",      # tfstate読み取り
      ]
    }
    tfmigrate-apply = {
      id           = "tfmigrate-apply"
      display_name = "tfmigrate Apply Service Account"
      description  = "Service Account for tfmigrate apply operations"
      roles = [
        "roles/storage.admin",             # tfstate読み書き
      ]
    }
  }
}

# Create service accounts
resource "google_service_account" "tfactions" {
  for_each = local.service_accounts

  project      = var.base_project_id
  account_id   = each.value.id
  display_name = each.value.display_name
  description  = each.value.description
}

# Workload Identity User binding for each service account
resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = local.service_accounts

  service_account_id = google_service_account.tfactions[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# Project-level IAM bindings for each service account
resource "google_project_iam_member" "tfactions_permissions" {
  for_each = merge([
    for sa_key, sa_config in local.service_accounts : {
      for role in sa_config.roles :
      "${sa_key}-${role}" => {
        service_account = google_service_account.tfactions[sa_key].email
        role            = role
      }
    }
  ]...)

  project = var.base_project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"
}
