provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  api_token = var.proxmox_api_token
  username  = var.proxmox_api_username
  password  = var.proxmox_api_password

  ssh {
    agent       = false
    username    = var.proxmox_ssh_user
    private_key = file(pathexpand(var.proxmox_ssh_private_key_file))
  }
}
