locals {
  ansible_inventory_path = "${path.module}/../ansible/environments/${var.environment_name}/inventory.yml"
}

resource "local_file" "ansible_inventory" {
  depends_on = [null_resource.bootstrap_ct_ssh]

  filename = local.ansible_inventory_path
  content = templatefile("${path.module}/../ansible/templates/inventory.yml.hcl", {
    bootstrap_cts = [for name, ve in proxmox_virtual_environment_container.cts : {
      name      = name
      ip        = ve.ipv4["eth0"]
      vm_id     = ve.vm_id
      node_name = ve.node_name
    } if contains(ve.tags, "bootstrap-app")]
    environment_name         = var.environment_name
    ansible_private_key_path = var.ansible_private_key_path
  })
}