resource "null_resource" "bootstrap_ct_ssh" {
  for_each   = proxmox_virtual_environment_container.ve
  depends_on = [proxmox_virtual_environment_container.ve]

  triggers = {
    ct_id = tostring(each.value.vm_id)
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
      "sudo pct exec ${each.value.vm_id} -- /bin/sh -lc 'apk update && apk add --no-cache openssh python3 && apk cache purge'",
      "sudo pct exec ${each.value.vm_id} -- /bin/sh -lc 'mkdir -p /etc/ssh/sshd_config.d && printf \"PasswordAuthentication no\\nKbdInteractiveAuthentication no\\nPermitRootLogin prohibit-password\\nPubkeyAuthentication yes\\n\" > /etc/ssh/sshd_config.d/99-bootstrap.conf'",
      "sudo pct exec ${each.value.vm_id} -- /bin/sh -lc 'rc-update add sshd default || true; service sshd restart || service sshd start'",
    ]
  }
}