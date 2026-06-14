resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "6.3.0"

  values = [
    <<-EOT
    loki:
      auth_enabled: false
      commonConfig:
        replication_factor: 1
      storage:
        type: filesystem
      schemaConfig:
        configs:
          - from: "2024-01-01"
            store: tsdb
            object_store: filesystem
            schema: v13
            index:
              prefix: loki_index_
              period: 24h
      deploymentMode: SingleBinary
      singleBinary:
        replicas: 1
        persistence:
          enabled: false
    enterprise:
      enabled: false
    gateway:
      enabled: false
    write:
      replicas: 0
    read:
      replicas: 0
    backend:
      replicas: 0
    resultsCache:
      enabled: false
    chunksCache:
      enabled: false
    EOT
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "3.1.0"

  values = [
    <<-EOT
    storage:
      type: memory
    provisionDataStore:
      cassandra: false
      elasticsearch: false
      kafka: false
    allInOne:
      enabled: true
      image:
        repository: jaegertracing/all-in-one
        tag: 1.55.0
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - ${var.jaeger_domain}
    query:
      enabled: false
    collector:
      enabled: false
    agent:
      enabled: false
    EOT
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "58.1.3"

  values = [
    <<-EOT
    grafana:
      enabled: true
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - ${var.grafana_domain}
      additionalDataSources:
        - name: Loki
          type: loki
          access: proxy
          url: http://loki:3100
          jsonData:
            maxLines: 1000
        - name: Jaeger
          type: jaeger
          access: proxy
          url: http://jaeger-query:16686
          jsonData:
            tracesToLogsV2:
              datasourceUid: 'Loki'
              spanStartTimeShift: '1h'
              spanEndTimeShift: '1h'
              tags: ['job', 'instance', 'pod', 'namespace']
    prometheus:
      prometheusSpec:
        serviceMonitorSelectorNilUsesHelmValues: false
        podMonitorSelectorNilUsesHelmValues: false
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - ${var.prometheus_domain}
        paths:
          - /
    alertmanager:
      enabled: false
    EOT
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.loki,
    helm_release.jaeger
  ]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "6.15.3"

  values = [
    <<-EOT
    config:
      clients:
        - url: http://loki:3100/loki/api/v1/push
    EOT
  ]

  depends_on = [
    helm_release.loki
  ]
}
