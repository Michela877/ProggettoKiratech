provider "virtualbox" {}

variable "vm_details" {
  default = [
    { name = "controller", hostname = "controller.example.com", cpu = 1, memory = 2048 },
    { name = "master", hostname = "master.example.com", cpu = 2, memory = 4096 },
    { name = "nodeone", hostname = "nodeone.example.com", cpu = 1, memory = 4096 },
    { name = "nodetwo", hostname = "nodetwo.example.com", cpu = 1, memory = 4096 }
  ]
}

resource "virtualbox_vm" "vms" {
  for_each = { for vm in var.vm_details : vm.name => vm }
  
  name           = each.value.name
  cpu            = each.value.cpu
  memory         = each.value.memory
  image          = "/path/to/iso/image.iso" # Cambia con il percorso della tua ISO
  network_adapter {
    type           = "bridged"
    bridge         = "enp0s3" # Cambia con il nome corretto della scheda bridge sulla tua macchina
  }

  # Disks
  disk {
    size   = 10240 # 10 GiB
    type   = "normal"
  }
}

output "vm_ips" {
  value = {
    for vm in virtualbox_vm.vms :
    vm.name => vm.ip_address
  }
}
