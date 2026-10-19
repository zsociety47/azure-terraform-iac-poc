# A slice of the virtual network.
# Referencing the virtual network makes Terraform wait until that network exists.
# This block does not mention the network security group. The association file attaches it later.

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}
