# ==========================================
# Local Kubernetes Platform Configuration
# ==========================================

# Cluster Config
cluster_name    = "platform-cluster"
kubeconfig_path = "~/.kube/config"

# Namespaces
ingress_namespace          = "ingress-nginx"
cert_manager_namespace     = "cert-manager"
monitoring_namespace       = "monitoring"
external_secrets_namespace = "external-secrets"
vault_namespace            = "vault"

# Local Ingress Domains (mapped via /etc/hosts)
example_domain    = "example-app.local"
grafana_domain    = "grafana.local"
prometheus_domain = "prometheus.local"
jaeger_domain     = "jaeger.local"

# Security & Secrets Configuration
vault_root_token = "vault-root-token"
