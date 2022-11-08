terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}

locals {
  #first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
  location= "East US"
}

#commented out because of the spanish inquistion (more like I got a duplicate provider configuration error)
# provider "azurerm" {
#   features {}
# }

resource "azurerm_resource_group" "Contaynement" {
  name     = "Contaynement"
  location = local.location
}

resource "azurerm_virtual_network" "darknet" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub_sandwich" {
  name                 = "sub_sandwich"
  resource_group_name  = azurerm_resource_group.Contaynement.name
  virtual_network_name = azurerm_virtual_network.darknet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "stretch_armstrong" {
  name                = "stretch_armstrong"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  sku                 = "Standard_B2s"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.sub_sandwich
    }
  }
}