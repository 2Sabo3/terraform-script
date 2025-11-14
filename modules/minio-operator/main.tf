resource "kubernetes_namespace" "minio" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "minio_operator" {
  name             = "minio-operator"
  chart            = "${path.module}/charts/operator-5.0.14.tgz"
  namespace        = kubernetes_namespace.minio.metadata[0].name
  create_namespace = false

  values = [<<-EOF
  rbac:
    create: true
  metrics:
    enabled: true
  EOF
  ]

  timeout = 600
  atomic  = true
}

output "namespace" {
  value = var.namespace
}
