terraform {
  required_version = ">=1.3.9"

  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "terraformsimplon"
    container_name       = "states"
    key                  = "networking"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.47.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a1f74e2d-ec58-4f9a-a112-088e3469febb"
  client_id       = "f9e9511a-594a-4104-ab7b-b768fe4a1439"
  client_secret   = var.client_secret
  tenant_id       = "a2e466aa-4f86-4545-b5b8-97da7c8febf3"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }

  # localhost registry with password protection
  /*registry {
    url = "oci://localhost:5000"
    username = "username"
    password = "password"
  }

  # private registry
  registry {
    url = "oci://private.registry"
    username = "username"
    password = "password"
  }*/
}