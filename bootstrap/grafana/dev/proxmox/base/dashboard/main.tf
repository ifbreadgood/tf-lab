terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.25.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

provider "grafana" {
  url  = "https://grafana.trial.studio"
}

resource "grafana_data_source" "victoria_metrics" {
  name       = "victoria-metrics"
  type       = "victoriametrics-metrics-datasource"
  url        = "http://victoria-metrics:8428"
  is_default = true
}

resource "grafana_data_source" "victoria_metrics_prometheus" {
  name = "victoria-metrics-prometheus"
  type = "prometheus"
  url  = "http://victoria-metrics:8428"
}

resource "grafana_data_source" "victoria_logs" {
  name = "victoria-logs"
  type = "victoriametrics-logs-datasource"
  url  = "http://victoria-logs:9428"
}

data "http" "node_exporter" {
  url = "https://grafana.com/api/dashboards/1860/revisions/41/download"
}

resource "grafana_folder" "infrastructure" {
  title = "infrastructure"
}
resource "grafana_dashboard" "node_exporter" {
  folder      = grafana_folder.infrastructure.id
  config_json = data.http.node_exporter.response_body
}

data "http" "k8s-system-api-server" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-api-server.json"
}
data "http" "k8s-system-coredns" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json"
}
data "http" "k8s-views-global" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json"
}
data "http" "k8s-views-namespaces" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json"
}
data "http" "k8s-views-nodes" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-nodes.json"
}
data "http" "k8s-views-pods" {
  url = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json"
}
resource "grafana_dashboard" "k8s-system-api-server" {
  config_json = data.http.k8s-system-api-server.response_body
  folder      = grafana_folder.infrastructure.id
}
resource "grafana_dashboard" "k8s-system-coredns" {
  config_json = data.http.k8s-system-coredns.response_body
  folder      = grafana_folder.infrastructure.id
}
resource "grafana_dashboard" "k8s-views-global" {
  config_json = data.http.k8s-views-global.response_body
  folder      = grafana_folder.infrastructure.id
}
resource "grafana_dashboard" "k8s-views-namespaces" {
  config_json = data.http.k8s-views-namespaces.response_body
  folder      = grafana_folder.infrastructure.id
}
resource "grafana_dashboard" "k8s-views-nodes" {
  config_json = data.http.k8s-views-nodes.response_body
  folder      = grafana_folder.infrastructure.id
}
resource "grafana_dashboard" "k8s-views-pods" {
  config_json = data.http.k8s-views-pods.response_body
  folder      = grafana_folder.infrastructure.id
}
