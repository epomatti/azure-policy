terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.81.0"
    }
  }
}

locals {
  workload = "bigfactory"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "storage" {
  source              = "./modules/storage"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}
