resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.28.1"
  namespace        = kubernetes_namespace.vault.metadata[0].name
  create_namespace = true

  values = [<<-EOF
  global:
    tlsDisable: true

  server:
    
    affinity: {}

    service:
      type: ClusterIP
      enabled: true
      port: 8200

    serviceAccount:
      create: true
      name: vault-server


    ha:
      enabled: false
      replicas: 2
      
      raft:
        enabled: true
        setNodeId: true

        storage:
          enabled: true
          size: 5Gi
          storageClass: standard
          accessMode: ReadWriteOnce
          mountPath: /vault/data

        config: |
          ui = true

          listener "tcp" {
            address = "0.0.0.0:8200"
            cluster_address = "0.0.0.0:8201"
            tls_disable = 1
          }

          storage "raft" {
            path = "/vault/data"
          }

          service_registration "kubernetes" {}

    ui:
      enabled: true

  injector:
    enabled: false
  EOF
  ]
}
