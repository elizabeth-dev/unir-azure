terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "=2.98.0"
		}

    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "=2.2.0"
    }
	}
}

resource "azurerm_resource_group" "rg" {
  name = "k8s_rg"
  location = var.location
}

resource "azurerm_storage_account" "stAcc" {
  name = var.storage_account
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}
