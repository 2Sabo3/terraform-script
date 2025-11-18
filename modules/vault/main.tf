resource "helm_release" "vault" {
  name       = "vault"
  chart      = "vault"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.vault_chart_version
  namespace  = var.namespace

  values = [<<EOF
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
      enabled: true
      replicas: 3
      raft:
        enabled: false

      config: |
        ui = true

        listener "tcp" {
          address         = "0.0.0.0:8200"
          cluster_address = "0.0.0.0:8201"
          tls_disable     = 1
        }

        storage "postgresql" {
          connection_url = "${var.connection_url}"
          table          = "vault_kv_store"
          ha_enabled     = "true"
          ha_table       = "vault_ha_locks"
        }

        service_registration "kubernetes" {}

        api_addr      = "http://vault.vault.svc.cluster.local:8200"
        cluster_addr  = "https://vault.vault.svc.cluster.local:8201"
        
      ui:
        enabled: true

      dataStorage:
        enabled: false
      
      auditStorage:
        enabled: false

      injector:
        enabled: false
EOF
  ]


  
}
