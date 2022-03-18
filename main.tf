# Create a resource group if it doesn't exist
module "resource-group" {
  source         = "./modules/resource-group"
  node_location  = var.node_location
  resource_group = var.resource_group
}

# Create virtual network
module "virtual-network" {
  source         = "./modules/virtual-network"
  node_location  = var.node_location
  resource_group = var.resource_group
  depends_on     = [module.resource-group]
}

# Create subnet
module "subnet" {
  source         = "./modules/subnet"
  resource_group = var.resource_group
  depends_on     = [module.virtual-network]
}

# output "subnet_id" {
#   value = data.azurerm_subnet.myterraformsubnet.id
# }

# resource "azurerm_public_ip" "myterraformpublicip" {
#   name                = "TF-VM2-IP"
#   location            = var.node_location
#   resource_group_name = var.resource_group
#   allocation_method   = "Dynamic"

#   tags = {
#     environment = "Terraform Demo"
#   }
# }

# resource "azurerm_network_interface" "myterraformnic" {
#   name                = "TF-VM2-NIC"
#   location            = var.node_location
#   resource_group_name = var.resource_group

#   ip_configuration {
#     name                          = "myNicConfiguration"
#     subnet_id                     = data.azurerm_subnet.myterraformsubnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
#   }

#   tags = {
#     environment = "Terraform Demo"
#   }
# }

# resource "azurerm_linux_virtual_machine" "myterraformvm" {
#   name                            = "TF-VM2"
#   location                        = var.node_location
#   resource_group_name             = var.resource_group
#   network_interface_ids           = [azurerm_network_interface.myterraformnic.id]
#   size                            = "Standard_DS1_v2"
#   computer_name                   = "TF-VM2"
#   disable_password_authentication = "false"
#   admin_username                  = var.ansible_user
#   admin_password                  = var.ansible_pass

#   os_disk {
#     name                 = "TF-VM2-OsDisk"
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   tags = {
#     environment = "Terraform Demo"
#   }
# }

# data "azurerm_public_ip" "myterraformpublicip" {
#   name                = azurerm_public_ip.myterraformpublicip.name
#   resource_group_name = var.resource_group
#   depends_on          = [azurerm_linux_virtual_machine.myterraformvm]
# }

# output "public_ip_address" {
#   value      = data.azurerm_public_ip.myterraformpublicip.ip_address
#   depends_on = [azurerm_linux_virtual_machine.myterraformvm]
# }

# resource "null_resource" "previous" {}

# resource "time_sleep" "wait_30_seconds" {
#   depends_on = [null_resource.previous]

#   create_duration = "45s"
# }

### The Ansible inventory file
# resource "local_file" "AnsibleInventory" {
#   content = templatefile("ansible/inventory.tmpl",
#     {
#       ansible-pass  = var.ansible_pass
#       ansible-user  = var.ansible_user
#       myterraformvm = data.azurerm_public_ip.myterraformpublicip.ip_address
#     }
#   )
#   filename   = "ansible/inventory"
#   depends_on = [azurerm_linux_virtual_machine.myterraformvm]
# }

# resource "null_resource" "run-ansible" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ansible/inventory ansible/playbook.yml"
#   }
#   depends_on = [azurerm_linux_virtual_machine.myterraformvm, time_sleep.wait_30_seconds]
# }