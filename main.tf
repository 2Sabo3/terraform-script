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
  source     = "./modules/vault"
  namespace  = var.vault_namespace
  vault_chart_version = "0.21.0"
  connection_url = module.postgresql.connection_url
  depends_on = [ module.postgresql ]
}

# MinIO Operator Module 
module "minio_operator" {
  source     = "./modules/minio-operator"
  kubeconfig = var.kubeconfig
  namespace  = var.minio_namespace
}

# Vault PostgreSQL Connection Module
module "postgresql" {
  source = "./modules/vault-postgresql-connection"
  namespace = "vault"
  username = "vaultuser"
  password = "VaultSecurePass123!"
  database = "vault"
  postgres_root_pass = "PostgresRootPass123!"
  postgres_chart_version = "15.5.32"

  connection_url = "postgres://vaultuser:VaultSecurePass123!@postgresql.vault.svc.cluster.local:5432/vault?sslmode=disable"

}


# Vault <-> MinIO connection module
 module "vault_initialize" {
   source = "./modules/vault-minio-connection"
   depends_on = [ module.vault, module.minio_operator ]
   namespace = var.vault_namespace
   kes_policy_path = var.kes_policy_path
   policy_name = var.policy_name
   approle_name = var.approle_name
 }


 #Prometheus Monitoring Module

 module "prometheus" {
   source = "./modules/prometheus"
 }

 #Grafana Monitoring Module

 module "grafana" {
   source = "./modules/grafana"
 }

 #Promtail Logging Module

 module "promtail" {
   source = "./modules/promtail"
 }

 #Loki Logging Module

  module "loki" {
    source = "./modules/loki"
  }

 #ServiceMonitor for Application Metrics

 #module "service_monitor" {
 #  source = "./modules/service-monitor"
 #}
