# The network that later subnets are cut from.
# Referencing the resource group makes Terraform wait until that group exists.

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  tags                = var.tags
}
