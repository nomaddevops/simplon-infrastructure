name = "joff"

charts = {
  nginx-ingress-controller = {
    create_namespace = true
    repository       = "https://charts.bitnami.com/bitnami"
    version          = "9.4.1"
    sets             = {
      "service.loadBalancerIP" = "20.101.234.17"
    }
    skip_crds        = false
  }
  /*cert-manager = {
    create_namespace = true
    repository       = "https://charts.jetstack.io"
    version          = "v1.11.1"
    sets             = {
      "installCRDs" = true
    }
    skip_crds        = false
  }*/
  redis = {
    create_namespace = true
    repository       = "https://charts.bitnami.com/bitnami"
    version          = "v17.9.2"
    skip_crds        = false
    sets = {
      "global.redis.password" = "plop",
      "replica.replicaCount"  = 1
    }
  }
}