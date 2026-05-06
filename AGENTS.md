# AGENTS

Purpose: keep automation in this repo predictable and minimal. Remember: KISS, DRY, YAGNI.
Do not grow dramatically the Readme file.
Document only necessary things, such as description, usage, troubleshooting in the docs/ dir.

## Scope

- Terraform creates one Alpine LXC in Proxmox.
- Terraform bootstraps SSH/Python in the container.
- Terraform writes Ansible inventory from provider IP on `eth0`.
- Ansible runs `playbooks/site.yml`.

## Task usage

- Examples of environments: `dev-1`, `stage`, `prod`. It is exntendable.
- Main commands:
  - `task deploy ENVIRONMENT=dev-1`
  - `task terraform:plan ENVIRONMENT=dev-1`
  - `task ansible:apply ENVIRONMENT=dev-1`
  - `task destroy ENVIRONMENT=dev-1`
  - `task envrionment:generate`
  Do not add any task without special approval. If you want to add a task, you probably don't want to.

## Safety

- `destroy` is blocked for `ENVIRONMENT=production`.
- Terraform uses `init -lockfile=readonly`.
- secrets stored in secrets.tfvars

## Layout

- Terraform env files: `terraform/environments/<env>.tfvars`
- Secrets: `terraform/secrets.tfvars`
- Ansible inventory: `ansible/environment/<env>/inventory.ini`
- Ansible group vars: `ansible/environment/<env>/group_vars/<env>.yml`
