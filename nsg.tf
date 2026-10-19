# The firewall for the subnet. No custom rules are declared.
# Azure still applies its default rules once the association file attaches this group.
# This block does not name the subnet. The association file does that.

resource "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}
