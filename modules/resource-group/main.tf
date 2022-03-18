# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = var.resource_group
  location = var.node_location

  tags = {
    environment = "Terraform Demo"
  }
}
