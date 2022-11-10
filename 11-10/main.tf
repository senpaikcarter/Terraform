terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  first_public_key = file("~/.ssh/azurevm.pub")
  location         = "East US"
}

resource "azurerm_resource_group" "Contaynement" {
  name     = "Contaynement"
  location = local.location
}

resource "azurerm_virtual_network" "darknet" {
  name                = "darknet"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  address_space       = ["10.0.0.0/16"]
}

#Network Security Group Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_network_security_group" "Julio" {
  name                = "Julio"
  location            = local.location
  resource_group_name = azurerm_resource_group.Contaynement.name

  security_rule {
    name                       = "donttouchthat"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

#Public IP Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_public_ip" "PublicIP12345" {
  name                = "PublicIP12345"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

#Public IP Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_public_ip" "PublicIP12345variable" {
  count = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}-public-ip"
  resource_group_name = azurerm_resource_group.Contaynement.name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

#Darknet Subnet's Start Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_subnet" "sub_sandwich" {
  name                 = "sub_sandwich"
  resource_group_name  = azurerm_resource_group.Contaynement.name
  virtual_network_name = azurerm_virtual_network.darknet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Resource Group Dingus Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_resource_group" "Dingus" {
  name     = "Dingus"
  location = local.location
  tags = {
    environment = "Production"
  }
}
#Network Noirnet Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_virtual_network" "noirnet" {
  name                = "noirnet"
  resource_group_name = azurerm_resource_group.Dingus.name
  location            = local.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "Production"
  }
}
#Subnet nourasubnet Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_subnet" "nourasubnet" {
  name                 = "nourasubnet"
  resource_group_name  = azurerm_resource_group.Dingus.name
  virtual_network_name = azurerm_virtual_network.noirnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#NIC Card Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_network_interface" "nic" {
  count = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}-nic"
  location            = local.location
  resource_group_name = azurerm_resource_group.Dingus.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nourasubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP12345.id
  }
  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}" #name constructed using count and prefix
  resource_group_name = azurerm_resource_group.Dingus.name
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
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
  tags = {
    environment = "Production"
  }
}


# output "VMSS-IP" {
#   description = "this is the output for the IP address"
#   value = azurerm_linux_virtual_machine_scale_set.reginald.ip
# }

# output "VM-SSH-Key" {
#   description = "The VM Public IP is:"
#   value = azurerm_linux_virtual_machine.exceptionaldingus.admin_ssh_key
# }

# output "VM-ID" {
#   description = "The VM ID is:"
#   value = azurerm_linux_virtual_machine_scale_set.reginald.id
# }

output "VM-IP" {
  description = "The VM IP Address is:"
  value       = azurerm_linux_virtual_machine.exceptionaldingus.public_ip_address
}