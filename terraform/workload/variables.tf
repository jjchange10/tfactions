variable "base_project_id" {
  type = string
}

variable "region" {
  type = string
  default = "asia-northeast1"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in the format 'owner/repo'"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "github-pool"
}

variable "workload_identity_provider_id" {
  type        = string
  description = "Workload Identity Provider ID"
  default     = "github-provider"
}
