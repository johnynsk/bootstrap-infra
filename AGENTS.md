# AGENTS

Purpose: keep automation in this repo predictable and minimal. Remember: KISS, DRY, YAGNI.
When you're writing anything, firstly follow this instructions and secondly investigate and follow the industry standards.
Any sensitive env information (such as postgres credentials) should be in a environments directory in format `<environment_name>.env`

## Documenting

Do not grow dramatically the Readme file.
Document only necessary things, such as description, usage, troubleshooting in the docs/ dir.
Documentation should be written in declarative style. Do not write documentation in style "fixed something and etc." When you're working on documentation, load the DocOps/Senior Tech Writer skills.

## Ansible

Any ansible code should be idempontent. Roles may be called in any order. They should be ready to be called from a new different playbook.
Inventory should be only one per-environment. If one environment deploys multiple services, the inventory file should be one, as a terraform code.
If you're planning to add a new role/collection, which already exists and implemented (in ansible galaxy), you should use it. It is covered by code and reporting all CVEs via dependency trackers and keeps my mind not to check sonarqube for every external plugin.

If product uses integration with such service as postgres, it prepare role and database first, and clean-up it in case of teardown. 

## Scope

- Terraform creates one Alpine LXC in Proxmox.
- Terraform bootstraps SSH/Python in the container.
- Terraform writes Ansible inventory, detecting IP from provider on `eth0` interface.
- Ansible runs `playbooks/site.yml`.

## Task usage

- Examples of environments: `dev-1`, `stage`, `prod`. It is exntendable.
- Main commands:
  - `task deploy`
  - `task terraform:plan`
  - `task ansible:apply`
  - `task destroy`
  - `task envrionment:generate`

Do not add any task without special approval. If you want to add a task, you probably don't want to.
In some cases there could be extra task `ansible:teardown`

## Safety

- `destroy` is blocked for `ENVIRONMENT=production`.
- Terraform uses `init -lockfile=readonly`.
- secrets stored in secrets.tfvars

## Layout

- Terraform env files: `terraform/environments/<env>.tfvars`
- Secrets: `terraform/secrets.tfvars`
- Ansible inventory: `ansible/environment/<env>/inventory.ini`
- Ansible group vars: `ansible/environment/<env>/group_vars/<env>.yml`
