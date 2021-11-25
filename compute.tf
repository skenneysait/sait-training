
data "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  virtual_network_name = "myTFVnet"
  resource_group_name  = "TrainingResourceGroup"
}

data "azurerm_storage_account" "example" {
  name                = "oneofakindstoreage31"
  resource_group_name = "TrainingResourceGroup"
}

output "subnet_id" {
  value = data.azurerm_subnet.myterraformsubnet.id
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = "Canada East"
  resource_group_name = "TrainingResourceGroup"
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform Demo"
  }
}

output "public_ip" {
  value = azurerm_public_ip.myterraformpublicip.ip_address
}

resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = "Canada East"
  resource_group_name = "TrainingResourceGroup"

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

resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "myVM1"
  location              = "Canada East"
  resource_group_name   = "TrainingResourceGroup"
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm1"
  disable_password_authentication = "false"
  admin_username                  = var.ansible_user
  admin_password                  = var.ansible_pass

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.example.primary_blob_endpoint
  }

  tags = {
    environment = "Terraform Demo"
  }
}

data "azurerm_public_ip" "myterraformpublicip" {
  name                = azurerm_public_ip.myterraformpublicip.name
  resource_group_name = "TrainingResourceGroup"
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.myterraformpublicip.ip_address
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("ansible/inventory.tmpl",
    {
      ansible-pass  = var.ansible_pass
      ansible-user  = var.ansible_user
      myterraformvm = data.azurerm_public_ip.myterraformpublicip.ip_address
    }
  )
  filename   = "ansible/inventory"
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}


resource "null_resource" "run-ansible" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${data.azurerm_public_ip.myterraformpublicip.ip_address}, ansible/playbook.yml"
  }
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}