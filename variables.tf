# Names, region, addresses, and tags for this build.
# The provider is already configured. Resource files read these values
# so a name is written once and reused everywhere.

variable "location" {
  description = "Azure region for every resource in this build."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the network."
  type        = string
  default     = "rg-tf-poc-zeon01"
}

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-tf-poc"
}

variable "subnet_name" {
  description = "Name of the subnet inside the virtual network."
  type        = string
  default     = "snet-backend"
}

variable "network_security_group_name" {
  description = "Name of the network security group attached to the subnet."
  type        = string
  default     = "nsg-web"
}

variable "address_space" {
  description = "Address space of the virtual network. The subnet prefix must fit inside it."
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefix of the subnet. This is a slice of the virtual network address space."
  type        = list(string)
  default     = ["10.2.1.0/24"]
}

variable "tags" {
  description = "Tags on the resource group, virtual network, and network security group."
  type        = map(string)
  default = {
    project     = "azure-terraform-iac-poc"
    environment = "poc"
    managed-by  = "terraform"
    owner       = "zeon"
  }
}
