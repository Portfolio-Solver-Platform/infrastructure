variable "project_id" {
  description = "The ID of the Google Cloud Project."
  type        = string
}

variable "region" {
  description = "The region for resources."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The zone for resources."
  type        = string
  default     = "europe-west1-a"
}

variable "secrets_manager_transit_machine_type" {
  description = "The machine type for the transit secrets manager."
  type        = string
  default     = "e2-micro"
}

variable "secrets_manager_transit_region" {
  description = "The zone for the transit secrets manager."
  type        = string
  default     = "us-central1"
}

variable "secrets_manager_transit_zone" {
  description = "The zone for the transit secrets manager."
  type        = string
  default     = "us-central1-a"
}

variable "psp_cluster_deletion_protection" {
  description = "Whether to enable deletion protection on the PSP cluster. If enabled, the cluster cannot be deleted through automated tools. This avoids accidental deletions via a bad CI/CD run. Recommended for production."
  type = bool
  default = true
}
