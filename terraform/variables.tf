variable "environment_name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "vm_id" {
  type     = number
  default  = null
  nullable = true
}

variable "ipv4_address" {
  description = "Static IPv4 CIDR, required only when ipv4_mode is static."
  type        = string
  default     = null
  nullable    = true
}

variable "gateway" {
  description = "Gateway, required only when ipv4_mode is static."
  type        = string
  default     = null
  nullable    = true
}

variable "ipv4_mode" {
  description = "IPv4 mode: static or dhcp."
  type        = string
  default     = "static"

  validation {
    condition     = contains(["static", "dhcp"], var.ipv4_mode)
    error_message = "ipv4_mode must be one of: static, dhcp."
  }
}

variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_insecure" {
  type    = bool
  default = true
}

variable "lxc_template_file_id" {
  type = string
}

variable "ansible_private_key_path" {
  type = string
}

variable "ansible_public_key_path" {
  type = string
}

variable "ct_initial_password" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "proxmox_ssh_host" {
  type = string
}

variable "proxmox_ssh_user" {
  type    = string
  default = "root"
}

variable "proxmox_ssh_private_key_file" {
  type = string
}
