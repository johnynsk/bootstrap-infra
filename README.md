# bootstrap-infra

Minimal IaC for one Alpine LXC on Proxmox.

- Terraform deploys container, ready to connect by SSH.
- Ansible `site.yml` runs connectivity check.

## Config files

Secrets: `terraform/terraform.tfvars.example` -> `terraform/terraform.tfvars`

Environment config starts from `terraform/environments/env.tfvars.example` -> `terraform/environments/dev-1.tfvars`, `terraform/environments/stage.tfvars`, `terraform/environments/prod.tfvars`

Network example:

```hcl
ipv4_mode    = "static"
ipv4_address = "192.168.1.2/24"
gateway      = "192.168.1.1"
# or just a
ipv4_mode    = "dhcp"
```

## Commands

```bash
task terraform:init ENVIRONMENT=dev-1
task terraform:plan ENVIRONMENT=dev-1
task terraform:apply ENVIRONMENT=dev-1
task ansible:galaxy
task ansible:apply ENVIRONMENT=dev-1
task environment:generate
```
