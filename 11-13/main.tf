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

#Resource Group Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_resource_group" "Production" {
  name     = "Production"
  location = var.location
  tags = {
    environment = "Production"
  }
}

#Locals Block Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
# locals { #commented out for vairable.tf testing 
#   first_public_key = file("~/.ssh/azurevm.pub")
#   location         = "East US"
# }

#Azure Virtual Network Darknet Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_virtual_network" "darknet" {
  name                = "darknet"
  resource_group_name = azurerm_resource_group.Production.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags = var.tags
}

#Darknet Subnet's Start Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_subnet" "sub_sandwich" {
  name                 = "sub_sandwich"
  resource_group_name  = azurerm_resource_group.Production.name
  virtual_network_name = azurerm_virtual_network.darknet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#NSG Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_network_security_group" "Julio" {
  name                = "Julio"
  location            = var.location
  resource_group_name = azurerm_resource_group.Production.name
  
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

  tags = var.tags
}

#Public IP Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_public_ip" "PublicIPProduction" {
  count = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}-public-ip"
  resource_group_name = azurerm_resource_group.Production.name
  location            = var.location
  allocation_method   = "Static"
  tags = var.tags
}

#NIC Card Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_network_interface" "nic" {
  count = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.Production.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub_sandwich.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIPProduction[count.index].id
  }
  tags = var.tags
}

#Azure Linux Virtual Machine Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.vm_name_pfx}-${count.index}" #name constructed using count and prefix
  resource_group_name = azurerm_resource_group.Production.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.first_public_key)
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
  tags = var.tags
}

output "VM-IP" {
  description = "The VM's IP Addresses are:"
  value       = [for public_ip_address in azurerm_linux_virtual_machine.vm : public_ip_address.public_ip_address ]
  sensitive = false
}