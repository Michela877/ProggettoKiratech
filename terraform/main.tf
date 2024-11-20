terraform {
  required_providers {
    hyperv = {
      source  = "hashicorp/hyperv"
      version = "1.0.0"  # Assicurati di usare una versione compatibile
    }
  }
}

provider "hyperv" {
  host = "localhost"  # Indica l'host di Hyper-V, "localhost" se è sulla stessa macchina
}

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

resource "hyperv_virtual_machine" "vms" {
  for_each = { for vm in var.vm_details : vm.name => vm }

  name      = each.value.hostname
  cpu_count = each.value.cpu
  memory_startup_bytes = each.value.memory * 1024 * 1024  # Converti MB in byte

  # Configurazione del disco
  disk {
    name            = "${each.value.name}-disk.vhdx"
    size            = 20 # GB
    type            = "dynamic"  # Tipo di disco dinamico che si espande quando viene scritto
  }

  # Configurazione della rete
  network_adapter {
    switch_name = "Default Switch"  # Cambia con il nome del tuo switch virtuale
    static_mac_address = "00-15-5D-00-00-01"  # (opzionale) MAC address statico
  }

  # Configurazione del CD-ROM per l'ISO
  dvd_drive {
    path = "C:/Users/User/Downloads/CentOS-Stream-9-latest-x86_64-dvd1.iso"  # Cambia con il percorso dell'ISO
  }

  # Aggiungi eventuali altre configurazioni come necessarie
}

output "vm_ips" {
  description = "IP addresses of the VMs"
  value = { for vm in hyperv_virtual_machine.vms : vm.name => vm.ip_address }
}

