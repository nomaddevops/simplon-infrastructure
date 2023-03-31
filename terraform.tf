
/* 
Le module network sert a deployer le resource group mais aussi le virtual network et d'autre éléments réseau
Le module est construit de façon a être le plus réutilisable possible ça évite de réécrire du code pour rien
*/
module "network" {
  source = "/Users/joffrey.dupire/Documents/Terraform/Modules/azure_resource_group"

  location      = var.location
  subnet_config = var.subnet_config
}


/*
Maintenant que les bases réseaux sont déployé et pour plus de facilité ici car c'est une petite infrastructure 
je crée directement le cluster AKS, les paramètres pouvant varier je n'utilise que des variables

Je récupère des éléments de sortie du module network pour m'assurer que je déploie dans la même région
et dans le bon resource group
*/
resource "azurerm_kubernetes_cluster" "aks" {
  name                = format("%s-%s", var.name, terraform.workspace)
  location            = module.network.resource_group.location
  resource_group_name = module.network.resource_group.name
  dns_prefix          = format("%s-%s", var.name, terraform.workspace)

  default_node_pool {
    name       = var.aks_node_pool_config.default.name
    node_count = var.aks_node_pool_config.default.node_count
    vm_size    = var.aks_node_pool_config.default.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

/*
 J'ai maintenant le cluster pret a acceuillir des pods/servicse etc cependant je n'ai aucun Ingress Controller.
 En utilisant Helm Chart je déploie mon controller nginx (j'utilise un chart de la communauté) et je fais pareil
 avec cert-manager qui est l'outils pour gérer les certificats HTTPS, et enfin redis.

 Je passe volontairement avec les Charts de la communauté pour simplifier, je n'ai pas besoin de re-coder
 quelque chose que le constructeur fera mieux que moi! Cependant ça ne m'empeche pas d'aller voir comment 
 ils ont fait (On ne sait jamais dans certains cas je pourrais avoir a le faire moi même).

 N'oubliez pas l'acronyme KISS (Keep It Simple Stupid https://en.wikipedia.org/wiki/KISS_principle ), 
 ou le rasoir d'Occam (shorturl.at/eBEFV)
*/

# UPDATE YOUR KUBE CONFIG OTHERWISE HELM WILL NOT BE ABLE TO DEPLOY THE CHART 

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress-controller"
  namespace        = "nginx-ingress-controller"
  create_namespace = true
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "nginx-ingress-controller"
  version          = "9.4.1"


  depends_on = [
    azurerm_kubernetes_cluster.aks,
    module.network
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  create_namespace = true
  namespace        = "cert-manager"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "cert-manager"
  skip_crds        = false
  version          = "v0.9.4"
  depends_on = [
    helm_release.nginx_ingress,
    azurerm_kubernetes_cluster.aks,
    module.network
  ]
}

resource "helm_release" "redis" {
  name             = "redis"
  create_namespace = true
  namespace        = "redis"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  skip_crds        = false
  version          = "v17.9.2"

  set {
    name  = "global.redis.password"
    value = "yolo"
  }
  set {
    name  = "replica.replicaCount"
    value = 1
  }

  depends_on = [
    helm_release.nginx_ingress,
    azurerm_kubernetes_cluster.aks,
    module.network
  ]
}