output "linux_public_ip" {
  description = "Public IP address of deployed VM"
  value       = azurerm_linux_virtual_machine.myterraformvm.*.public_ip_address
}