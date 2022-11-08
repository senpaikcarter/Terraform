terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  first_public_key = file("~/.ssh/azurevm.pub")
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

resource "azurerm_linux_virtual_machine_scale_set" "reginald" {
  name                = "reginald"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  sku                 = "Standard_B2s"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
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
      subnet_id = azurerm_subnet.sub_sandwich.id
    }
  }
}

resource "azurerm_resource_group" "Dingus" {
  name     = "Dingus"
  location = local.location
}

resource "azurerm_virtual_network" "noirnet" {
  name                = "noirnet"
  resource_group_name = azurerm_resource_group.Dingus.name
  location            = local.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "nourasubnet" {
  name                 = "nourasubnet"
  resource_group_name  = azurerm_resource_group.Dingus.name
  virtual_network_name = azurerm_virtual_network.noirnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NICcard" {
  name                = "NICcard"
  location            = local.location
  resource_group_name = azurerm_resource_group.Dingus.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nourasubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "exceptionaldingus" {
  name                = "exceptionaldingus"
  resource_group_name = azurerm_resource_group.Dingus.name
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.NICcard.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azurevm.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
