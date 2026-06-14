resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  version    = "1.14.4"

  values = [
    <<-EOT
    installCRDs: true
    EOT
  ]

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

resource "kubectl_manifest" "selfsigned_issuer" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: selfsigned-issuer
    spec:
      selfSigned: {}
  YAML

  depends_on = [
    helm_release.cert_manager
  ]
}
