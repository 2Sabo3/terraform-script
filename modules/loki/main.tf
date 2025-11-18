resource "helm_release" "loki" {
  name              = var.name
  namespace         = var.namespace
  repository        = "https://grafana.github.io/helm-charts"
  chart             = "loki"
  version           = var.chart_version
  create_namespace  = true

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      

      resultsCache = {
        enabled = false
      }

      loki = {
        auth_enabled   = false
        useTestSchema  = true

        storage = {
          type = "filesystem"
          bucketNames = {
            chunks = "loki-chunks"
            ruler  = "loki-ruler"
            admin  = "loki-admin"
          }
        }

        storage_config = {
          filesystem = {
            # ⭐ Correct persistent path
            directory = "/var/loki/chunks"
          }
        }

        ingester = {
          chunk_idle_period   = "3m"
          chunk_retain_period = "1m"
        }

        limits_config = {
          reject_old_samples         = true
          reject_old_samples_max_age = "168h"
        }

        server = {
          http_listen_port = 3100
          grpc_listen_port = 9095
          log_level        = "info"
        }
      }

      # ─────────────────────────────────────────
      # SINGLE-BINARY MODE
      # ─────────────────────────────────────────
      singleBinary = {
        replicas = 1

        persistence = {
          enabled          = true
          size             = "10Gi"
          storageClassName = "standard"

          # ❌ mountPath removed (chart already uses /var/loki)
        }

        securityContext = {
          fsGroup      = 10001
          runAsUser    = 10001
          runAsNonRoot = true
        }

        containerSecurityContext = {
          readOnlyRootFilesystem    = false
          allowPrivilegeEscalation  = true
        }
      }

      # Disable other modes
      backend = { replicas = 0 }
      read    = { replicas = 0 }
      write   = { replicas = 0 }
      ingester = { replicas = 0 }
    })
  ]
}
