output "connection_url" {
  value = var.connection_url
}

output "postgres_service" {
  value = "postgresql.${var.namespace}.svc.cluster.local"
}
