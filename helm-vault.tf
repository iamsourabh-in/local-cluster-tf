resource "kubernetes_namespace" "vault" {
  depends_on = [kind_cluster.default]
  metadata {
    name = var.vault_namespace
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  version    = "0.28.0"

  values = [
    <<-EOT
    server:
      dev:
        enabled: true
        devRootToken: "${var.vault_root_token}"
      service:
        enabled: true
    EOT
  ]

  depends_on = [
    kubernetes_namespace.vault
  ]
}

resource "kubectl_manifest" "vault_seeding_job" {
  validate_schema = false
  force_new       = true
  yaml_body = <<-YAML
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: vault-seeding-job
      namespace: ${var.vault_namespace}
    spec:
      template:
        spec:
          containers:
          - name: vault-seeding
            image: hashicorp/vault:1.16.1
            command: ["/bin/sh", "-c"]
            args:
            - |
              set -e
              export VAULT_ADDR="http://vault.${var.vault_namespace}.svc.cluster.local:8200"
              export VAULT_TOKEN="${var.vault_root_token}"
              
              echo "Waiting for Vault to be ready..."
              until vault status > /dev/null 2>&1; do
                sleep 2
              done
              echo "Vault is ready!"
              
              # Enable K8s Auth
              vault auth enable kubernetes || true
              
              # Configure K8s Auth
              vault write auth/kubernetes/config \
                kubernetes_host="https://kubernetes.default.svc"
              
              # Write policy
              vault policy write example-policy - <<EOF
              path "secret/data/database/credentials" {
                capabilities = ["read"]
              }
              EOF
              
              # Create role for ESO
              vault write auth/kubernetes/role/external-secrets-role \
                bound_service_account_names=external-secrets \
                bound_service_account_namespaces=${var.external_secrets_namespace} \
                policies=example-policy \
                ttl=24h
              
              # Write secret
              vault kv put secret/database/credentials \
                database-user="vault-admin-db" \
                database-password="VaultSuperSecretPassword456"
              
              echo "Seeding completed successfully!"
          restartPolicy: OnFailure
      backoffLimit: 4
  YAML

  depends_on = [
    helm_release.vault
  ]
}
