variable "vm_details" {
  description = "Details of the VMs to create"
  type        = list(object({
    name     = string
    hostname = string
    cpu      = number
    memory   = number
  }))
}
