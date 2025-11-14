variable "kubeconfig" {
  type        = string
  default     = "C:\\Users\\vishal.pathak\\.kube\\config"
  description = "Path to kubeconfig file"
}

variable "vault_namespace" {
  type    = string
  default = "vault"
}

variable "minio_namespace" {
  type    = string
  default = "minio-operator"
}

variable "kes_policy_path" {
  type = string
  default = "./modules/vault-minio-connection/kes-policy/kes-policy.hcl"
}

variable "policy_name" {
  type = string
  default = "minio-test"
}

variable "approle_name" {
  type = string
  default = "minio-approle"
}

