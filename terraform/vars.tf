variable "vm_size" {
  type = string
  description = "VM size for the nodes"
  default = "Standard_B2s"
}

variable "vms" {
  type = map(string)
  description = "Nodes to create"
  default = {
    "master" = "10.0.1.10"
    "worker" = "10.0.1.11"
  }
}