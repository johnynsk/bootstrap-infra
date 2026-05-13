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
ANSIBLE_TMPL_DIR="$ROOT_DIR/ansible/templates"
ENV_DIR="$ROOT_DIR/environments"
ENV_EXAMPLE="$ENV_DIR/template.env"

usage() {
  echo "Usage: $0 <env-name>"
  echo "Example: $0 dev-1"
  exit 1
}

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing template: $1" >&2
    exit 1
  fi
}

IS_SKIPPED=0
write_if_missing() {
  target="$1"
  shift

  if [ -e "$target" ]; then
    IS_SKIPPED=1
    echo "Skipping existing file: $target"
    return 0
  fi

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT HUP INT TERM
  "$@" > "$tmp"
  mv "$tmp" "$target"
  trap - EXIT HUP INT TERM
  rm -f "$tmp"
}

[ -n "$ENV_NAME" ] || usage

require_file "$TF_TMPL_DIR/terraform.tfvars"
require_file "$TF_TMPL_DIR/state.name.hcl"
require_file "$ANSIBLE_TMPL_DIR/group_vars_all.yml"
require_file "$ENV_EXAMPLE"

mkdir -p "$TF_ENV_DIR/$ENV_NAME"

write_if_missing "$TF_ENV_DIR/$ENV_NAME/terraform.tfvars" sh -c \
  'ENVIRONMENT="$1" PROJECT="bootstrap" envsubst < "$2"' sh "$ENV_NAME" "$TF_TMPL_DIR/terraform.tfvars"

write_if_missing "$TF_ENV_DIR/$ENV_NAME/state.name.hcl" sh -c \
  'ENVIRONMENT="$1" PROJECT="bootstrap" envsubst < "$2"' sh "$ENV_NAME" "$TF_TMPL_DIR/state.name.hcl"

mkdir -p "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars"

write_if_missing "$ANSIBLE_ENV_DIR/$ENV_NAME/inventory.yml" sh -c \
  'printf "%s\n" "---" "# Call terraform apply to fill out this inventory"' sh

write_if_missing "$ANSIBLE_ENV_DIR/$ENV_NAME/group_vars/all.yml" sh -c \
  'ENVIRONMENT="$1" PROJECT="bootstrap" envsubst < "$2"' sh "$ENV_NAME" "$ANSIBLE_TMPL_DIR/group_vars_all.yml"

write_if_missing "$ENV_DIR/$PROJECT-$ENV_NAME.env" sh -c \
  'ENVIRONMENT="$1" envsubst < "$2"' sh "$ENV_NAME" "$ENV_EXAMPLE"

if [ -n "$IS_SKIPPED" ]; then
  echo "To re-generate existing files, remove it first."
fi