output "vm_ips" {
  description = "IP addresses of the VMs"
  value       = { for vm in virtualbox_vm.vms : vm.name => vm.ip_address }
}
