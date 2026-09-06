#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
terraform_dir="${1:-$repo_root/terraform}"
private_key="${2:-$HOME/.ssh/travelmemory_ed25519}"
output="${3:-$repo_root/ansible/inventory/hosts.yml}"

web_ip="$(terraform -chdir="$terraform_dir" output -raw web_public_ip)"
web_private_ip="$(terraform -chdir="$terraform_dir" output -raw web_private_ip)"
database_ip="$(terraform -chdir="$terraform_dir" output -raw database_private_ip)"
operator_cidr="$(terraform -chdir="$terraform_dir" output -raw operator_cidr)"
public_subnet_cidr="$(terraform -chdir="$terraform_dir" output -raw public_subnet_cidr)"

mkdir -p "$(dirname "$output")"
printf '%s\n' \
  'all:' \
  '  vars:' \
  '    ansible_user: ubuntu' \
  "    ansible_ssh_private_key_file: $private_key" \
  "    operator_cidr: $operator_cidr" \
  "    public_subnet_cidr: $public_subnet_cidr" \
  '  children:' \
  '    web:' \
  '      hosts:' \
  '        web1:' \
  "          ansible_host: $web_ip" \
  "          private_ip: $web_private_ip" \
  '    database:' \
  '      hosts:' \
  '        database1:' \
  "          ansible_host: $database_ip" \
  "          ansible_ssh_common_args: '-o ProxyJump=ubuntu@$web_ip'" > "$output"

echo "Wrote Ansible inventory to $output"
