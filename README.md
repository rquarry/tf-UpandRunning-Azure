# Azure Terraform Examples
Completing the examples from [__Terraform Up &amp; Running__](https://www.terraformupandrunning.com/) in aws would be too much of a copy operation. I decided to use Azure to create a more interesting learning experience. Each branch represents the order of the chapter work in the book, with **main** being the working tree at any given time. 

# Chapter 2

This configuration is a tab bit more complex in Azure, but is more or less as described in the book. 

The [Azure Quickstart load balancer documents](https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-terraform) were a great way to validate the Terraform resources used, but they are always missing enough that hunting down further details in needed. For instance: Using [scale_sets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) versus VMs requires the use of ```depends_on``` to make sure creation happens in the right order. As the book points out sometimes you need to provide "extra hints" to the instantiation process.

### Azure CLI commands to check scale sets

- az vmss get-instance-view --resource-group TFResourceGroupG --name example-machine
- az vmss extension show --resource-group TFResourceGroupG --vmss-name example-machine --name busyboxhttpd
- az vmss list-instances --resource-group TFResourceGroupG --name example-machine --query "[].{instanceId:instanceId, extension:resources[].id, extProvisioningState:resources[].provisioningState}"


# Chapter 3

The chapter material using an AWS S3 bucket for backend storage is simple, and the directions using the [Azure CLI credentials](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#backend-azure-ad-user-via-azure-cli) (that you are probably already using) is just about the same. Issue #6 will create a better solution.

Per the book, all the backend details except individual keys were put into one .hcl file and called with in each init: `terraform init -backend-config=../backend.hcl`

This chapter raises an interesting point about the use of Azure ResourceGroups. When you manage parts of your infrastructure separately with remote backends and data sources, should the RGs be separate or can they be the same name?