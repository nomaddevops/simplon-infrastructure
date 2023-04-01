## Architecture 

The following schema represent the architecture wanted to deploy the Azure voting app on a production workload.

When you deployed an AKS, by default Azure will add a new resource group on our subscription composed with:
- Network Security Group
- Managed Identities
- Virtual Machine Scale Set
- Public IP
- Load Balancer

Keyvault will be used to store Redis secrets, such as the redis_passwd

Container Registry will be used to store the Docker Image built 

The managed identities will be used to allow instances running under the VMSS to have rights to get secrets from Keyvault and being allowed to pull an image from the ACR

![Infrastructure schema](docs/Simplon-Terraform-Infra.drawio.svg)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.47.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.50.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | /Users/joffrey.dupire/Documents/Terraform/Modules/azure_resource_group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.redis](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_node_pool_config"></a> [aks\_node\_pool\_config](#input\_aks\_node\_pool\_config) | n/a | `map` | <pre>{<br>  "default": {<br>    "name": "default",<br>    "node_count": 1,<br>    "vm_size": "Standard_D2_v2"<br>  }<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Azure Region name | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Generic name, enter your name to identify your resources | `string` | n/a | yes |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | Multi az deployment for subnets | `map` | <pre>{<br>  "private": {<br>    "is_multi_az": false<br>  },<br>  "public": {<br>    "is_multi_az": false<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to identify resources in billing mostly | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
