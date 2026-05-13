resource "proxmox_virtual_environment_container" "cts" {
  for_each  = var.ves
  node_name = each.value.pve.node
  vm_id     = each.value.vm_id

  unprivileged = true

  cpu {
    cores = each.value.cpu
  }

  memory {
    dedicated = each.value.memory
    swap      = each.value.swap
  }

  disk {
    datastore_id = each.value.system_disk_origin
    size         = each.value.system_disk_size_gb
  }

  initialization {
    hostname = each.value.hostname

    ip_config {
      ipv4 {
        address = each.value.network.mode == "dhcp" ? "dhcp" : each.value.network.address
        gateway = each.value.network.mode == "dhcp" ? null : each.value.network.gateway
      }
    }

    user_account {
      keys     = [trimspace(file(pathexpand(var.ansible_public_key_path)))]
      password = var.ct_initial_password
    }
  }

  network_interface {
    name   = "eth0"
    bridge = each.value.network.bridge
  }

  operating_system {
    template_file_id = each.value.os.template
    type             = each.value.os.family
  }

  wait_for_ip {
    ipv4 = true
  }

  started = true

  tags = [var.environment_name, each.value.label, var.project_name, "terraform", "ansible"]
}
