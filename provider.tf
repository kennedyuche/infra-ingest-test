terraform {
  backend "azurerm" {
    resource_group_name     = "k8s_test"
    resource_group_location = "eastus"
    storage_account_name    = "k8stfbackend"
    container_name          = "tfstate"
    key                     = "dev.terraform.tfstate"
  }
}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.95.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
