resource "helm_release" "grafana" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.chart_version
  create_namespace = true

  values = [
    yamlencode({
      adminUser     = var.admin_user
      adminPassword = var.admin_password

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [

            ## ---------------------------
            ## Prometheus Datasource
            ## ---------------------------
            {
              name      = "Prometheus"
              type      = "prometheus"
              access    = "proxy"
              url       = "http://prometheus-kube-prometheus-prometheus:9090"
              isDefault = true
            },

            ## ---------------------------
            ## Alertmanager Datasource
            ## ---------------------------
            {
              name   = "Alertmanager"
              type   = "alertmanager"
              access = "proxy"
              url    = "http://prometheus-kube-prometheus-alertmanager:9093"
            },

            ## ---------------------------
            ## Loki Datasource
            ## ---------------------------
            {
              name   = "Loki"
              type   = "loki"
              access = "proxy"
              url    = "http://loki:3100"
            }
          ]
        }
      }
    })
  ]
}
