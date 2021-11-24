module "ban-ss-server" {
  source            = "git::https://github.com/sait-ca/terraform-vmware-modules.git//vmware-compute"
  vmtemplate        = var.vmtemplate
  instances         = 2
  vmname            = "vweb170"
  vmfolder          = var.vm_folder
  compute_cluster   = var.compute_cluster
  cpu_number        = 4
  ram_size          = 8192
  network           = var.network
  ipv4submask       = var.ipv4submask
  vmdns             = var.vmdns
  dc                = var.dc
  datastore_cluster = var.datastore_cluster
  disk_size_gb      = var.disk_size_gb
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("ansible/inventory.tmpl",
    {
      ansible-pass      = var.ansible_pass
      ansible-user      = var.ansible_user
      ban-ss-server     = resource.linux.Linux-ip
    }
  )
  filename = "ansible/inventory"
}


resource "null_resource" "run-ansible" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/inventory playbook.yml" 
  }
  depends_on = [resource.ban-ss-serverr]
}