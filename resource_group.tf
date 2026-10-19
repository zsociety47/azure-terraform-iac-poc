# The container for every later resource.
# The virtual network file references this block, so Terraform creates the group first.

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
