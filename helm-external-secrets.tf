resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.9.20"

  values = [
    <<-EOT
    installCRDs: true
    EOT
  ]

  depends_on = [
    kubernetes_namespace.external_secrets
  ]
}

resource "kubectl_manifest" "fake_secret_store" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: fake-store
    spec:
      provider:
        fake:
          data:
            - key: /database/credentials
              valueMap:
                database-user: "eso-admin-db"
                database-password: "SuperSecretPassword123"
  YAML

  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubectl_manifest" "vault_secret_store" {
  validate_schema = false
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: vault-backend
    spec:
      provider:
        vault:
          server: "http://vault.vault.svc.cluster.local:8200"
          path: "secret"
          version: "v2"
          auth:
            kubernetes:
              mountPath: "kubernetes"
              role: "external-secrets-role"
              serviceAccountRef:
                name: "external-secrets"
                namespace: "external-secrets"
  YAML

  depends_on = [
    helm_release.external_secrets
  ]
}

