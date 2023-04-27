
/* 
Le module network sert a deployer le resource group mais aussi le virtual network et d'autre éléments réseau
Le module est construit de façon a être le plus réutilisable possible ça évite de réécrire du code pour rien
*/
module "network" {
  source = "git@github.com:nomaddevops/azure_resource_group?ref=v1.0.2"

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
    vnet_subnet_id = module.network.subnets.private.subnet.id
  }

  network_profile {
    network_plugin = "azure"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.identity.id ]
  }

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = format("mi-%s", var.name)
  resource_group_name = module.network.resource_group.name
  location            = module.network.resource_group.location
}

resource "azurerm_role_assignment" "role_assignment" {
    for_each             = {
    "Owner" = module.network.subnets.private.subnet.id
    }
    scope                = each.value
    role_definition_name = each.key
    principal_id         = azurerm_user_assigned_identity.identity.principal_id
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

resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename = ".kube/config"
}

resource "helm_release" "chart" {
  for_each         = var.charts
  name             = each.key
  namespace        = each.key
  create_namespace = each.value.create_namespace
  repository       = each.value.repository
  chart            = each.key
  version          = each.value.version
  skip_crds        = each.value.skip_crds

  dynamic "set" {
    for_each = each.value.sets
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    module.network,
    local_file.kube_config
  ]
}