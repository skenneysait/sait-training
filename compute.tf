data "azurerm_subnet" "myterraformsubnet" {
  name                 = "TF-Subnet"
  virtual_network_name = "TF-Vnet"
  resource_group_name  = "TF-ResourceGroup"
}
