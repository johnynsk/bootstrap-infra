#!/usr/bin/env sh
set -eu

ENV_NAME="${1:-}"
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TF_ENV_DIR="$ROOT_DIR/terraform/environments"
ANSIBLE_ENV_DIR="$ROOT_DIR/ansible/environment"
TF_EXAMPLE="$TF_ENV_DIR/env.tfvars.example"

usage() {
  echo "Usage: $0 <env-name>"
  echo "Example: $0 dev-1"
  exit 1
}

[ -n "$ENV_NAME" ] || usage
[ -f "$TF_EXAMPLE" ] || { echo "Missing template: $TF_EXAMPLE" >&2; exit 1; }

cp "$TF_EXAMPLE" "$TF_ENV_DIR/$ENV_NAME.tfvars"
mkdir -p "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars"
: > "$ANSIBLE_ENV_DIR/.gitkeep"
: > "$ANSIBLE_ENV_DIR/$ENV_NAME/.gitkeep"
: > "$ANSIBLE_ENV_DIR/$ENV_NAME/inventory.ini"
: > "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars/.gitkeep"
: > "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars/$ENV_NAME.yml"
