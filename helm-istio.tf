resource "kubernetes_namespace" "istio_system" {
  depends_on = [kind_cluster.default]
  metadata {
    name = var.istio_namespace
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  depends_on = [
    kubernetes_namespace.istio_system
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  depends_on = [
    helm_release.istio_base
  ]
}
