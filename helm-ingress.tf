resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  version    = "4.10.0"

  values = [
    <<-EOT
    controller:
      kind: DaemonSet
      hostPort:
        enabled: true
      nodeSelector:
        ingress-ready: "true"
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      service:
        type: ClusterIP
      watchIngressWithoutClass: true
    EOT
  ]

  depends_on = [
    kubernetes_namespace.ingress
  ]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.0"

  values = [
    <<-EOT
    args:
      - --kubelet-insecure-tls
    EOT
  ]

  depends_on = [
    kind_cluster.default
  ]
}
