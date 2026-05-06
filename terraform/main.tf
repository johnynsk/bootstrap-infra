locals {
  container_name         = "${var.environment_name}-alpine-01"
  ansible_inventory_path = "${path.module}/../ansible/environment/${var.environment_name}/inventory.ini"
}

resource "proxmox_virtual_environment_container" "alpine" {
  node_name = var.node_name
  vm_id     = var.vm_id

  unprivileged = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 768
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  initialization {
    hostname = local.container_name

    ip_config {
      ipv4 {
        address = var.ipv4_mode == "dhcp" ? "dhcp" : var.ipv4_address
        gateway = var.ipv4_mode == "dhcp" ? null : var.gateway
      }
    }

    user_account {
      keys     = [trimspace(file(pathexpand(var.ansible_public_key_path)))]
      password = var.ct_initial_password
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vnet0"
  }

  operating_system {
    template_file_id = var.lxc_template_file_id
    type             = "alpine"
  }

  wait_for_ip {
    ipv4 = true
  }

  started = true

  tags = [var.environment_name, "alpine", "ansible"]
}

resource "null_resource" "bootstrap_ct_ssh" {
  depends_on = [proxmox_virtual_environment_container.alpine]

  triggers = {
    ct_id      = tostring(proxmox_virtual_environment_container.alpine.vm_id)
    public_key = trimspace(file(pathexpand(var.ansible_public_key_path)))
  }

  connection {
    type        = "ssh"
    host        = var.proxmox_ssh_host
    user        = var.proxmox_ssh_user
    private_key = file(pathexpand(var.proxmox_ssh_private_key_file))
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "sudo pct exec ${proxmox_virtual_environment_container.alpine.vm_id} -- /bin/sh -lc 'apk update && apk add --no-cache openssh python3 && apk cache purge'",
      "sudo pct exec ${proxmox_virtual_environment_container.alpine.vm_id} -- /bin/sh -lc 'mkdir -p /etc/ssh/sshd_config.d && printf \"PasswordAuthentication no\\nKbdInteractiveAuthentication no\\nPermitRootLogin prohibit-password\\nPubkeyAuthentication yes\\n\" > /etc/ssh/sshd_config.d/99-bootstrap.conf'",
      "sudo pct exec ${proxmox_virtual_environment_container.alpine.vm_id} -- /bin/sh -lc 'rc-update add sshd default || true; service sshd restart || service sshd start'",
    ]
  }
}

resource "local_file" "ansible_inventory" {
  depends_on = [null_resource.bootstrap_ct_ssh]

  filename = local.ansible_inventory_path
  content  = <<-EOF
[${var.environment_name}]
${local.container_name} ansible_host=${proxmox_virtual_environment_container.alpine.ipv4["eth0"]} ansible_user=root ansible_ssh_private_key_file=${var.ansible_private_key_path} environment_name=${var.environment_name} pve_node=${var.node_name} vm_id=${proxmox_virtual_environment_container.alpine.vm_id}

[${var.environment_name}:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
}
