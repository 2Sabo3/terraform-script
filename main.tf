terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}

# Vault Module
module "vault" {
  source          = "./modules/vault"
  kubeconfig      = var.kubeconfig
  namespace = var.vault_namespace
}

# MinIO Operator Module
module "minio_operator" {
  source          = "./modules/minio-operator"
  kubeconfig      = var.kubeconfig
  namespace       = var.minio_namespace
}

# Vault Minio Connection
#module "vault_initialize" {
#  source = "./modules/vault-minio-connection"
#  depends_on = [ module.vault, module.minio_operator ]
#  namespace = var.vault_namespace
#  kes_policy_path = var.kes_policy_path
#  policy_name = var.policy_name
#  approle_name = var.approle_name
#}



