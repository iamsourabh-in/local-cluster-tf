output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = pathexpand(var.kubeconfig_path)
}

output "grafana_url" {
  description = "The local URL to access Grafana UI"
  value       = "http://${var.grafana_domain}"
}

output "prometheus_url" {
  description = "The local URL to access Prometheus UI"
  value       = "http://${var.prometheus_domain}"
}

output "jaeger_url" {
  description = "The local URL to access Jaeger UI"
  value       = "http://${var.jaeger_domain}"
}

output "otel_collector_internal_grpc" {
  description = "The cluster-internal OTLP gRPC endpoint for the OTel Collector"
  value       = "opentelemetry-collector.${var.monitoring_namespace}.svc.cluster.local:4317"
}

output "otel_collector_internal_http" {
  description = "The cluster-internal OTLP HTTP endpoint for the OTel Collector"
  value       = "opentelemetry-collector.${var.monitoring_namespace}.svc.cluster.local:4318"
}

output "instructions" {
  description = "Quick post-deployment instructions for local setup"
  value       = <<EOF

Platform environment has been provisioned successfully!

1. Update your local /etc/hosts file to access the dashboards and applications locally:
   Add the following line to /etc/hosts:
   127.0.0.1 ${var.grafana_domain} ${var.prometheus_domain} ${var.jaeger_domain} ${var.example_domain}

2. Access the UIs in your web browser:
   - Grafana: http://${var.grafana_domain} (Default Username: admin, Password: prom-operator)
   - Prometheus: http://${var.prometheus_domain}
   - Jaeger: http://${var.jaeger_domain}

3. To configure your application, send OTel metrics, traces, and logs to the collector:
   - OTLP gRPC endpoint: opentelemetry-collector.${var.monitoring_namespace}.svc.cluster.local:4317
   - OTLP HTTP endpoint: http://opentelemetry-collector.${var.monitoring_namespace}.svc.cluster.local:4318

EOF
}
