terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.86.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

terraform {
  #  #***************************************************
  #  # Use GitHub as the Terraform Backend (with state locking)

  # backend "http" {
  #   address        = "http://localhost:6061/?type=git&repository=git@github.com:skenneysait/terraform-backend.git&state=state.json&ref=main"
  #   lock_address   = "http://localhost:6061/?type=git&repository=git@github.com:skenneysait/terraform-backend.git&state=state.json&ref=main"
  #   unlock_address = "http://localhost:6061/?type=git&repository=git@github.com:skenneysait/terraform-backend.git&state=state.json&ref=main"
  # }

  backend "azurerm" {
    resource_group_name  = "TF-StorageAccount-RG"
    storage_account_name = "tfstorageaccountskenney"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    access_key           = "0FIyztv5RiAcSd17FBcSg+AF2810oHR3fddc2JR+oJVlgbvZhgP1UIn4HRre2awAY7O2DXkENQevabLdcjYDEg=="
  }
}