terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

#Provider Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
provider "azurerm" {
  features {}
}

#Locals Block Starts Here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#
# locals { #commented out for vairable.tf testing 
#   first_public_key = file("~/.ssh/azurevm.pub")
#   location         = "East US"
# }