name = "joff"

charts = {
  nginx-ingress-controller = {
    create_namespace = true
    repository       = "https://charts.bitnami.com/bitnami"
    version          = "9.4.1"
  }
  cert-manager = {
    create_namespace = true
    repository       = "https://charts.bitnami.com/bitnami"
    version          = "v0.9.4"
  }
  redis = {
    create_namespace = true
    repository       = "https://charts.bitnami.com/bitnami"
    version          = "v17.9.2"
  }
}