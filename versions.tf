# Pins the tool versions before any Azure resource is declared.
# terraform init reads this block and downloads the provider it names.
# Later resource files depend on that provider staying the same version.

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.9.0"
    }
  }
}
