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

resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "TF-VM2-IP"
  location            = "Canada Central"
  resource_group_name = "TF-ResourceGroup"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
  name                = "TF-VM2-NIC"
  location            = "Canada Central"
  resource_group_name = "TF-ResourceGroup"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = data.azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = "Terraform Demo"
  }
}
