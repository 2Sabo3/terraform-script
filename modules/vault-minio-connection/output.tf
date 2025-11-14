output "role_id_file" {
  value       = "${path.module}/vault-role-id.txt"
  description = "Path to file containing Vault ROLE_ID"
}

output "secret_id_file" {
  value       = "${path.module}/vault-secret-id.txt"
  description = "Path to file containing Vault SECRET_ID"
}
