data "azurerm_subnet" "myterraformsubnet" {
  name                 = "default"
  virtual_network_name = "TF-ResourceGroup-vnet"
  resource_group_name  = "TF-ResourceGroup"
}

data "azurerm_storage_account" "myterraformstorageaccount" {
  name                = "tfstorageaccount161"
  resource_group_name = "TF-ResourceGroup"
}

output "subnet_id" {
  value = data.azurerm_subnet.myterraformsubnet.id
}
