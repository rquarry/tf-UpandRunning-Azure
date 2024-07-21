# Azure Terraform Examples
Completing the examples from [__Terraform Up &amp; Running__](https://www.terraformupandrunning.com/) in aws would be too much of a copy operation. I decided to use Azure to create a more interesting learning experience. Each branch represents the order of the chapter work in the book, with **main** being the working tree at any given time. 

# Chapter 2

This configuration is a tab bit more complex in Azure, but is more or less as described in the book. 

The [Azure Quickstart load balancer documents](https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-terraform) were a great way to validate the Terraform resources used, but they are always missing enough that hunting down further details in needed. For instance: Using [scale_sets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) versus VMs requires the use of ```depends_on``` to make sure creation happens in the right order. As the book points out sometimes you need to provide "extra hints" to the instantiation process. 
