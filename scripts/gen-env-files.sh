#!/usr/bin/env sh
set -eu

ENV_NAME="${1:-}"
ENVIRONMENT="$ENV_NAME"
PROJECT="bootstrap-infra"
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform"
TF_TMPL_DIR="$TF_DIR/templates"
TF_ENV_DIR="$TF_DIR/environments"
ANSIBLE_ENV_DIR="$ROOT_DIR/ansible/environments"
ENV_DIR="$ROOT_DIR/environments"
ENV_EXAMPLE="$ENV_DIR/template.env"

usage() {
  echo "Usage: $0 <env-name>"
  echo "Example: $0 dev-1"
  exit 1
}

[ -n "$ENV_NAME" ] || usage
# [ -f "$TF_EXAMPLE" ] || { echo "Missing template: $TF_EXAMPLE" >&2; exit 1; }

mkdir -p "$TF_ENV_DIR/$ENV_NAME"
ENVIRONMENT="$ENV_NAME" PROJECT="bootstrap" envsubst < "$TF_TMPL_DIR/terraform.tfvars.tmpl" > "$TF_ENV_DIR/$ENV_NAME/terraform.tfvars"
ENVIRONMENT="$ENV_NAME" PROJECT="bootstrap" envsubst < "$TF_TMPL_DIR/state.name.tmpl"       > "$TF_ENV_DIR/$ENV_NAME/state.name"
mkdir -p "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars"
echo "---\n# Managed by terraform": > "$ANSIBLE_ENV_DIR/$ENV_NAME/inventory.yml"
: > "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars/all.yml"
ENVIRONMENT="$ENV_NAME" envsubst < "$ENV_EXAMPLE" > "$ENV_DIR/$PROJECT-$ENV_NAME.env"
