# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "S1SB1TST-myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.node_location
  resource_group_name = var.resource_group

  tags = {
    BusinessUnit = "ITS"
    Creator = "Shawn Kenney"
  }
}