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

# module "network-security-group" {
#   source         = "./modules/network-security-group"
#   node_location  = var.node_location
#   resource_group = var.resource_group
#   depends_on     = [module.subnet]
#   subnet_id      = module.subnet.subnet_id
# }

module "ssh-public-key" {
  source         = "./modules/ssh-public-key"
  node_location  = var.node_location
  resource_group = var.resource_group
  depends_on     = [module.network-security-group]
  public_key     = var.public_key
}

module "test" {
  source         = "./modules/virtual-machine"
  node_location  = var.node_location
  resource_group = var.resource_group
  depends_on     = [module.ssh-public-key]
  subnet_id      = module.subnet.subnet_id
  environment    = var.environment
  organization   = var.organization
  landscape      = var.landscape
  release        = var.release
  usage          = var.usage
  instance       = var.instance
  application    = var.application
  apphosttype    = "test"
  node_count     = var.test_instances
  public_key     = var.public_key
  ansible_user   = var.ansible_user
  ansible_pass   = var.ansible_pass
}

# Create Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("ansible/inventory.tmpl",
    {
      ansible-pass = var.ansible_pass
      ansible-user = var.ansible_user
      test         = module.test.linux_public_ip
    }
  )
  filename = "ansible/inventory"
}

# resource "null_resource" "run-ansible" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ansible/inventory ansible/playbook.yml"
#   }
#   depends_on = [azurerm_linux_virtual_machine.myterraformvm, time_sleep.wait_30_seconds]
# }