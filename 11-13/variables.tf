variable "vm_name_pfx" {
    description = "VM Names"
    default = "Virtual-Machine"
    type = string 
}

variable "vm_count" {
    description = "Number of Virtual Machines"
    default = 1
    type = string
}

variable "location" {
    description = "Location Variable for Resources"
    default = "East US"
    type = string
}

variable "first_public_key" {
    description = "public key for reaching out to linux virtual machines"
    default = "~/.ssh/azurevm.pub"
    type = string
}

variable "tags" {
    description = "tags for all resources big and small"
    default = {
        environment = "Production"
        owner = "Kenny"
        overlord = "Kenny"
    }
    type = map 
}