# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  count               = var.node_count
  name                = "${var.apphosttype}-vm${count.index + 1}-PublicIP"
  location            = var.node_location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"

  tags = {
    BusinessUnit = "ITS"
    Creator = "Shawn Kenney"
  }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  count               = var.node_count
  name                = "${var.apphosttype}vm${count.index + 1}NIC"
  location            = var.node_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.myterraformpublicip.*.id, count.index + 1)
  }

  tags = {
    BusinessUnit = "ITS"
    Creator = "Shawn Kenney"
  }
}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "mystorageaccount" {
#  count                    = var.node_count
#  name                     = lower("${var.environment}${var.apphosttype}vm${count.index + 1}StorageDiag")
#  resource_group_name      = var.resource_group
#  location                 = var.node_location
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#
#  tags = {
#    environment = "Terraform Demo"
#  }
#}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  count                 = var.node_count
  name                  = "${var.apphosttype}-vm${count.index + 1}"
  location              = var.node_location
  resource_group_name   = var.resource_group
  network_interface_ids = [element(azurerm_network_interface.myterraformnic.*.id, count.index + 1)]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.apphosttype}-vm${count.index + 1}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # source_image_reference {
  #   publisher = "RedHat"
  #   offer     = "RHEL-SAP-HA"
  #   sku       = "7_9"
  #   version   = "7.9.2021051501"
  # }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "${var.organization}-${var.landscape}-${var.release}-${var.usage}${var.instance}-${var.application}-${var.apphosttype}-vm${count.index + 1}"
  admin_username                  = var.ansible_user
  admin_password                  = var.ansible_pass
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.ansible_user
    public_key = var.public_key
  }

  #boot_diagnostics {
  #  storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  #}

  tags = {
    BusinessUnit = "ITS"
    Creator = "Shawn Kenney"
  }
}