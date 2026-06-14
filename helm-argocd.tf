resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "9.5.21"

  values = [
    <<-EOT
    configs:
      params:
        server.insecure: true

    server:
      ingress:
        enabled: true
        ingressClassName: nginx
        hostname: "${var.argocd_domain}"
        tls: true
        annotations:
          cert-manager.io/cluster-issuer: "selfsigned-issuer"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
          nginx.ingress.kubernetes.io/ssl-redirect: "true"
    EOT
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.ingress_nginx,
    kubectl_manifest.selfsigned_issuer
  ]
}
