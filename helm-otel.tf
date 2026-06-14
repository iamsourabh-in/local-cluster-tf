resource "helm_release" "opentelemetry_collector" {
  name       = "opentelemetry-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "0.88.0"

  values = [
    <<-EOT
    mode: deployment
    config:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318
      processors:
        batch: {}
        memory_limiter:
          check_interval: 5s
          limit_percentage: 80
          spike_limit_percentage: 20
      exporters:
        otlp/jaeger:
          endpoint: jaeger-collector:4317
          tls:
            insecure: true
        prometheus:
          endpoint: 0.0.0.0:8889
          namespace: otel
        otlphttp/loki:
          endpoint: http://loki:3100/otlp
          tls:
            insecure: true
      service:
        pipelines:
          traces:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [otlp/jaeger]
          metrics:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [prometheus]
          logs:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [otlphttp/loki]
    ports:
      otlp:
        enabled: true
        containerPort: 4317
        servicePort: 4317
        protocol: TCP
      otlp-http:
        enabled: true
        containerPort: 4318
        servicePort: 4318
        protocol: TCP
      prometheus:
        enabled: true
        containerPort: 8889
        servicePort: 8889
        protocol: TCP
    serviceMonitor:
      enabled: true
      extraLabels:
        release: kube-prometheus-stack
    EOT
  ]

  depends_on = [
    helm_release.kube_prometheus_stack,
    helm_release.loki,
    helm_release.jaeger
  ]
}
