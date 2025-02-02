# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  resource_group_name  = var.resource_group
  virtual_network_name = "S1SB1TST-myVnet"
  address_prefixes     = ["10.0.1.0/24"]
}