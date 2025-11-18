resource "kubernetes_namespace" "vault" {
  metadata { name = var.namespace }
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  version    = var.postgres_chart_version
  namespace  = var.namespace

  values = [<<-EOF
    image:
      registry: docker.io
      repository: bitnami/postgresql
      tag: "latest"

    auth:
      username: ${var.username}
      password: ${var.password}
      database: ${var.database}
      postgresPassword: ${var.postgres_root_pass}

    primary:
      persistence:
        enabled: true
        size: 10Gi
        storageClass: standard
    
      resources:
        requests:
            memory: "256Mi"
            cpu: "250m"
        limits:
            memory: "512Mi"
            cpu: "500m"
        
    metrics: 
      enabled: true
      image:
        registry: docker.io
        repository: bitnami/postgres-exporter
        tag: "latest"
      service:
        type: ClusterIP
       
  EOF
  ]
}

resource "kubernetes_job" "create_vault_tables" {
  metadata {
    name      = "create-vault-tables"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    template {
      metadata {
        name = "create-vault-tables"
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "create-tables"
          image = "bitnami/postgresql:latest"

          env {
            name  = "PGHOST"
            value = "postgresql.vault.svc.cluster.local"
          }

          env {
            name  = "PGPORT"
            value = "5432"
          }

          env {
            name  = "PGDATABASE"
            value = "${var.database}"
          }

          env {
            name  = "PGUSER"
            value = "${var.username}"
          }

          env {
            name  = "PGPASSWORD"
            value = "${var.password}"
          }

          command = [
            "/bin/sh",
            "-c",
            "echo 'Waiting for PostgreSQL...' && until psql -c '\\q'; do echo 'Still waiting...'; sleep 2; done && echo 'Creating vault_kv_store table...' && psql -c 'CREATE TABLE IF NOT EXISTS vault_kv_store (parent_path TEXT COLLATE \"C\" NOT NULL, path TEXT COLLATE \"C\" NOT NULL, key TEXT COLLATE \"C\" NOT NULL, value BYTEA, CONSTRAINT pkey PRIMARY KEY (path, key));' && echo 'Creating index...' && psql -c 'CREATE INDEX IF NOT EXISTS parent_path_idx ON vault_kv_store (parent_path);' && echo 'Creating vault_ha_locks table...' && psql -c 'CREATE TABLE IF NOT EXISTS vault_ha_locks (ha_key TEXT COLLATE \"C\" NOT NULL, ha_identity TEXT COLLATE \"C\" NOT NULL, ha_value TEXT COLLATE \"C\", valid_until TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT ha_key PRIMARY KEY (ha_key));' && echo 'Verifying tables...' && psql -c '\\dt' && psql -c '\\d vault_kv_store' && psql -c '\\d vault_ha_locks' && echo 'Done!'"
          ]
        }
      }
    }

    backoff_limit = 4
  }

  wait_for_completion = true
  timeouts {
    create = "5m"
  }

  depends_on = [helm_release.postgresql]
}
