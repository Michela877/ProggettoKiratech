variable "vm_details" {
  description = "Details of the VMs to create"
  type = list(object({
    name     = string
    hostname = string
    cpu      = number
    memory   = number
  }))
  default = [
    { name = "controller", hostname = "controller.example.com", cpu = 1, memory = 2048 },
    { name = "master", hostname = "master.example.com", cpu = 2, memory = 4096 },
    { name = "nodeone", hostname = "nodeone.example.com", cpu = 1, memory = 4096 },
    { name = "nodetwo", hostname = "nodetwo.example.com", cpu = 1, memory = 4096 }
  ]
}

resource "null_resource" "hyperv_vm" {
  for_each = { for vm in var.vm_details : vm.name => vm }

  provisioner "local-exec" {
    command = <<EOT
      powershell.exe -File create_hyperv_vm.ps1 -VMName "${each.value.name}" -Hostname "${each.value.hostname}" -CPUCount ${each.value.cpu} -MemoryMB ${each.value.memory} -DiskSizeGB 20 -ISOPath "C:/Users/User/Downloads/CentOS-Stream-9-latest-x86_64-dvd1.iso"
    EOT
  }
}

output "vm_names" {
  description = "Names of the created VMs"
  value = { for vm in var.vm_details : vm.name => vm.name }
}
