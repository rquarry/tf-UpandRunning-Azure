# configure Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
  }
  
  backend "azurerm" {
    key = "data-store/terraform.tfstate"
  }
  required_version = ">= 1.1.0"

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "TFResourceGroupG"
  location = "eastus2"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mysql_flexible_server" "az_flexsv1" {
  name                   = "web-backend-mysql-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.db_username
  administrator_password = var.db_password
  sku_name               = "B_Standard_B1s"
}

resource "azurerm_mysql_flexible_database" "az_flexdb1" {
  name                = "web-backend-mysql-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.az_flexsv1.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

