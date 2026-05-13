project_name     = "$PROJECT"
environment_name = "$ENVIRONMENT"
ipv4_mode        = "dhcp"

proxmox_ssh_host = "192.168.1.211"
node_name        = "pve1"

ves = {
  bootstrap-app01 = {
    hostname = "bootstrap-app-dev-1"
    cpu      = 1
    vm_id    = null
    memory   = 256
    swap     = 0
    pve = {
      node     = "pve1"
      ssh_host = "192.168.1.211"
    }
    system_disk_size_gb = 1
    system_disk_origin  = "local-lvm"
    label               = "bootstrap-app"
    network = {
      mode    = "dhcp"
      address = null
      gateway = null
      bridge  = "vnet0"
    }
    os = {
      family   = "alpine",
      template = "local:vztmpl/alpine-3.23-default_20260116_amd64.tar.xz"
    }
  }
}
