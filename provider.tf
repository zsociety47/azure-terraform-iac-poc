# Signs in to Azure before any resource file runs.
# Later resource files use this provider. They do not sign in themselves.
#
# Authentication uses the Azure command-line interface (CLI) login already
# on this machine. The subscription id is read from the ARM_SUBSCRIPTION_ID
# environment variable, so it is not stored in this file. ARM is the prefix
# the Azure Resource Manager provider uses for its environment variables.

provider "azurerm" {
  # Do not register Azure resource providers during apply.
  # Microsoft.Network is already registered on this subscription.
  resource_provider_registrations = "none"

  # Required by the provider even when no feature flags are set.
  features {}
}
