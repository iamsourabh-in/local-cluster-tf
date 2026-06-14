variable "cluster_name" {
  description = "The name of the KinD cluster"
  type        = string
  default     = "platform-cluster"
}

variable "kubeconfig_path" {
  description = "Path to write the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring tools (Prometheus, Loki, Jaeger, OTel)"
  type        = string
  default     = "monitoring"
}

variable "ingress_namespace" {
  description = "Namespace for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
}

variable "cert_manager_namespace" {
  description = "Namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "grafana_domain" {
  description = "Local domain for Grafana UI"
  type        = string
  default     = "grafana.local"
}

variable "jaeger_domain" {
  description = "Local domain for Jaeger UI"
  type        = string
  default     = "jaeger.local"
}

variable "prometheus_domain" {
  description = "Local domain for Prometheus UI"
  type        = string
  default     = "prometheus.local"
}

variable "example_domain" {
  description = "Local domain for the example application"
  type        = string
  default     = "example-app.local"
}
