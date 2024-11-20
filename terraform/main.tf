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

  name   = each.value.hostname
  cpus   = each.value.cpu
  memory = each.value.memory
  image  = "C:/Users/User/Downloads/CentOS-Stream-9-latest-x86_64-dvd1.iso" # Cambia con il percorso corretto della tua ISO

  # Storage Controller
  storage_controller {
    name  = "SATA Controller"
    type  = "sata"
  }

  # Disks
  disk {
    name = "${each.value.name}-disk.vdi"
    size = 20480 # 20 GiB
  }

  # Network
  network_adapter {
    type           = "Scheda con bridge"
    bridge_adapter = "Realtek Gaming 2.5GbE Family Controller" # Cambia con il nome corretto della scheda bridge
  }
}

output "vm_ips" {
  value = {
    for vm in virtualbox_vm.vms : vm.name => vm.ipv4_address
  }
}
