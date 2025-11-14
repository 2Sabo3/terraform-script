resource "null_resource" "vault_initialize" {
  depends_on = [var.depends_on_helm_release]

  provisioner "local-exec" {
    command = "${path.module}/scripts/vault_init.sh ${var.namespace} ${path.module}/kes-policy/kes-policy.hcl ${var.policy_name} ${var.approle_name}"
    interpreter = ["C://Program Files//Git//bin//bash.exe", "-c"]
  }
}

