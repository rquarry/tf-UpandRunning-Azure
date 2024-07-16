# configure Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "TFResourceGroupG"
  location = "eastus2"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmip" {
  name                = "pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "example" {
  count               = 3
  name                = "example-nic${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal${count.index}"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "networksg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # RDP
  security_rule {
    name                       = "RDP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Web

  security_rule {
    name                       = "HTTP"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.http_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                     = azurerm_subnet.example.id
  network_security_group_id     = azurerm_network_security_group.networksg.id
}

### END OF NETWORK SECTION ####################################################

resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                = "Standard_F2"
  instances          = 3
  admin_username      = "adminuser"

  network_interface {
    name = "internal_nic"
    primary = true
  
    ip_configuration {
      name = "internal"
      primary = true
      subnet_id = azurerm_subnet.example.id
      load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.example.id ]
    }
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}

resource "azurerm_virtual_machine_scale_set_extension" "httpcmd" {
  name        = "busyboxhttpd"
  virtual_machine_scale_set_id  = azurerm_linux_virtual_machine_scale_set.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "echo 'hello world' > index.html && nohup busybox httpd -f -p ${var.http_server_port} &"
 }
SETTINGS
  
}

### END OF COMPUTE SECTION

resource "azurerm_lb" "example" {
  name                = "HTTPLoadBalancer"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmip.id
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = 3
  network_interface_id    = azurerm_network_interface.example[count.index].id
  ip_configuration_name = "internal${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id 
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "HTTPApplicationPool"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.http_server_port
  backend_port                   = var.http_server_port
  frontend_ip_configuration_name = "PublicIPAddress"
}
