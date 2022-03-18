# Add public key to VM
resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = "ssh_public_key"
  resource_group_name = var.resource_group
  location            = var.node_location
  public_key          = var.public_key
}
