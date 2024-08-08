# configure Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cloud_storage" {
  name     = "CentralStorage"
  location = "eastus2"
}

resource "azurerm_storage_account" "persistent_storage" {
  name                     = "persistentStorage"
  resource_group_name      = azurerm_resource_group.cloud_storage.name
  location                 = azurerm_resource_group.cloud_storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

 }

 resource "azurerm_storage_container" "tfStorage" {
  name = "tfStateStorage"
  storage_account_name = azurerm_storage_account.persistent_storage.name
  container_access_type = "private"
 }

 resource "azurerm_storage_blob" "tfStateStorage" {
   name = "tfStateStorage"
   storage_account_name = azurerm_storage_account.persistent_storage.name
   storage_container_name = azurerm_storage_container.tfStorage.name
   type = "Block"
 }