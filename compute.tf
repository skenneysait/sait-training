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

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "linuxkey" {
  filename="linuxkey.pem"
  content=tls_private_key.linux_key.private_key_pem
}

resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "TF-VM2"
  location              = "Canada Central"
  resource_group_name   = "TF-ResourceGroup"
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_DS1_v2"
  computer_name                   = "TF-VM2"
  #disable_password_authentication = "false"
  admin_username                  = var.ansible_user
  #admin_password                  = var.ansible_pass

  admin_ssh_key {
    username = var.ansible_user
    public_key = tls_private_key.linux_key.public_key_openssh
  }
  
  os_disk {
    name                 = "TF-VM2-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  depends_on = [
    tls_private_key.linux_key
  ]

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.myterraformstorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "Terraform Demo"
  }
}

data "azurerm_public_ip" "myterraformpublicip" {
  name                = azurerm_public_ip.myterraformpublicip.name
  resource_group_name = "TF-ResourceGroup"
  depends_on          = [azurerm_linux_virtual_machine.myterraformvm]
}

output "public_ip_address" {
  value      = data.azurerm_public_ip.myterraformpublicip.ip_address
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}
