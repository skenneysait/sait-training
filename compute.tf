resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "myVM1"
  location              = "Canada East"
  resource_group_name   = "TrainingResourceGroup"
  network_interface_ids = ["537dd924-559f-4a2a-9ccf-1440a5403e60"]
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
  admin_username                  = "azureuser"
  admin_password                  = "SuperSecretPassword55"

  boot_diagnostics {
    storage_account_uri = "oneofakindstoreage31"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("ansible/inventory.tmpl",
    {
      ansible-pass  = var.ansible_pass
      ansible-user  = var.ansible_user
      myterraformvm = azurerm_linux_virtual_machine.myterraformvm.Linux-ip
    }
  )
  filename = "ansible/inventory"
}


resource "null_resource" "run-ansible" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory ansible/playbook.yml"
  }
  depends_on = [azurerm_linux_virtual_machine.myterraformvm]
}