variable "namespace" {
  type        = string
  default     = "vault"
  description = "Namespace where Vault is deployed"
}

variable "kes_policy_path" {
  type        = string
  description = "Path to the KES policy HCL file"
}

variable "policy_name" {
  type        = string
  description = "Name of the policy to create in Vault"
}

variable "approle_name" {
  type        = string
  description = "AppRole name for KES"
}

variable "depends_on_helm_release" {
  description = "Helm release dependency for Vault"
  default     = null
}

