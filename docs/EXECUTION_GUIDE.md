# TravelMemory AWS Deployment Execution Guide

This runbook is both the operator guide and implementation report for the Terraform/Ansible assignment. Commands target Ubuntu under WSL2 and run from the repository root unless stated otherwise.

## 1. Component interaction

Terraform creates a VPC in `us-east-1`, public/private subnets, an Internet Gateway, NAT Gateway, route tables, security groups, one EC2 role/profile, and two Ubuntu EC2 instances. Only the web host receives a public IP.

Ansible connects to the web host directly and reaches the private database through SSH ProxyJump. The `common` role hardens SSH and enables UFW. The `mongodb` role installs MongoDB 7, creates administrator/application users, enables authorization, and binds to the private address. The `web` role installs Node.js 20, Nginx and PM2, builds React, and starts Express on localhost port 3001. Nginx serves React and proxies `/trip` and `/hello`.

## 2. Install WSL2 and tools

In Administrator PowerShell:

```powershell
wsl --install -d Ubuntu
```

Restart if requested, open Ubuntu, and run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ansible-core curl git gnupg jq openssh-client unzip wget

curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
rm -rf /tmp/aws /tmp/aws-install
unzip -q /tmp/awscliv2.zip -d /tmp/aws-install
sudo /tmp/aws-install/aws/install --update

wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

aws --version
terraform version
ansible --version
```

## 3. Configure AWS and SSH

Use an approved IAM identity, not the root account. Never place AWS credentials in this repository.

```bash
aws configure
aws configure set region us-east-1
aws sts get-caller-identity
ssh-keygen -t ed25519 -f ~/.ssh/travelmemory_ed25519 -C travelmemory-assignment
chmod 600 ~/.ssh/travelmemory_ed25519
chmod 644 ~/.ssh/travelmemory_ed25519.pub
```

Capture screenshot 01 with the account ID partly redacted. Terraform imports only the public key.

## 4. Clone and prepare inputs

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/travelmemory-aws-iac.git
cd travelmemory-aws-iac
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
OPERATOR_IP="$(curl -4 -fsSL https://checkip.amazonaws.com | tr -d '[:space:]')"
printf '%s/32\n' "$OPERATOR_IP"
```

Set the real values in `terraform/terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
project_name        = "travelmemory-aws-iac"
operator_cidr       = "YOUR_PUBLIC_IPV4/32"
ssh_public_key_path = "~/.ssh/travelmemory_ed25519.pub"
```

If the public IP changes, update `operator_cidr` and reapply Terraform before SSH.

## 5. Validate and create infrastructure

```bash
terraform -chdir=terraform fmt -check -diff
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=travelmemory.tfplan
```

Review the saved plan: it must contain exactly two EC2 instances, and only the web host may have a public IP. Capture screenshots 02 and 03, then apply:

```bash
terraform -chdir=terraform apply travelmemory.tfplan
terraform -chdir=terraform output
```

Capture screenshots 04–08. The NAT Gateway is now chargeable; continue without leaving the environment idle.

## 6. Generate inventory and verify SSH

```bash
chmod +x scripts/generate-inventory.sh
./scripts/generate-inventory.sh terraform ~/.ssh/travelmemory_ed25519 ansible/inventory/hosts.yml
ansible-inventory -i ansible/inventory/hosts.yml --graph

WEB_IP="$(terraform -chdir=terraform output -raw web_public_ip)"
DB_IP="$(terraform -chdir=terraform output -raw database_private_ip)"
ssh -i ~/.ssh/travelmemory_ed25519 ubuntu@"$WEB_IP" 'hostname'
ssh -i ~/.ssh/travelmemory_ed25519 -J ubuntu@"$WEB_IP" ubuntu@"$DB_IP" 'hostname'
```

Accept host keys only after checking the presented hosts. Capture screenshots 09 and 10. A PowerShell inventory generator is also available as `scripts/generate-inventory.ps1`.

## 7. Create the encrypted vault

```bash
cp ansible/vault.example.yml ansible/group_vars/all/vault.yml
ansible-vault edit ansible/group_vars/all/vault.yml
head -n 1 ansible/group_vars/all/vault.yml
```

Replace both example passwords with different long random values. The final command must show an `$ANSIBLE_VAULT;` header. Do not commit the vault password or show secret values in screenshots.

## 8. Validate and deploy with Ansible

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ansible -i ansible/inventory/hosts.yml all -m ping
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml --syntax-check --ask-vault-pass
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml --ask-vault-pass
```

Capture screenshots 11 and 12. Run the identical playbook command again for screenshot 13. A React production build can rerun; packages, firewall rules, users, and configuration should have no unexpected changes.

## 9. Verify services and security

```bash
ansible -i ansible/inventory/hosts.yml web -b -a 'systemctl is-active nginx'
ansible -i ansible/inventory/hosts.yml web -a 'pm2 status'
curl -fsS "http://$WEB_IP/hello"
```

Expected response: `Hello World!`. Capture screenshot 14.

Connect to the database without exposing credentials:

```bash
ssh -i ~/.ssh/travelmemory_ed25519 -J ubuntu@"$WEB_IP" ubuntu@"$DB_IP"
sudo systemctl is-active mongod
sudo ufw status verbose
mongosh --quiet --host 127.0.0.1 --eval 'db.runCommand({ping:1})'
exit
```

The unauthenticated MongoDB operation must fail after authorization is enabled. Perform an authenticated ping using values viewed locally with `ansible-vault view`; prevent credentials from entering shell history or screenshots. Capture screenshots 15 and 16. Never create a public MongoDB rule for testing.

## 10. Demonstrate application persistence

```bash
terraform -chdir=terraform output -raw application_url
```

Open the URL and:

1. Capture the home page as screenshot 17.
2. Complete the add-experience form and capture screenshot 18.
3. Submit a distinctive sample trip.
4. Refresh and capture the persisted record as screenshot 19.
5. Capture a successful `/trip` request in browser Developer Tools as screenshot 20.

Troubleshoot the web tier with `sudo nginx -t`, `sudo journalctl -u nginx`, `pm2 logs --lines 100`, and `curl http://127.0.0.1:3001/hello` on the web host.

## 11. Review and publish safely

```bash
git status --short
git ls-files | grep -E '(tfstate|terraform\.tfvars|vault\.yml|hosts\.yml|\.env$|\.pem$|\.key$)' && echo 'STOP: sensitive file tracked' || true
git grep -nE 'AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|EC) PRIVATE KEY' && echo 'STOP: possible secret' || true
```

After both checks are clean, create the public `travelmemory-aws-iac` repository, add it as `origin`, and push the reviewed branch. Capture screenshot 21. Commit only redacted evidence.

## 12. Destroy chargeable resources

This is the reviewed-plan equivalent of an interactive `terraform destroy` and makes the destructive change auditable before execution.

```bash
terraform -chdir=terraform plan -destroy -out=destroy.tfplan
terraform -chdir=terraform apply destroy.tfplan
```

Capture screenshot 22. Verify in AWS that both instances are terminated, the NAT Gateway is deleted, its Elastic IP is released, and no unexpected volume or public address remains. Capture screenshot 23. Do not delete Terraform state until destruction is confirmed, and never commit it.

## Troubleshooting

| Symptom | Check and resolution |
| --- | --- |
| Terraform authorization failure | Verify `aws sts get-caller-identity`; use an approved identity with VPC, EC2, EIP, and IAM permissions. |
| SSH timeout to web | Recheck the current public IP; update `operator_cidr` and apply again. |
| Private SSH timeout | Test web SSH first; confirm ProxyJump and the database TCP 22 rule from the public-subnet CIDR. |
| Ansible host-key failure | Connect manually and verify fingerprints before retrying. |
| MongoDB apt failure | Confirm the NAT Gateway is available and the private default route targets it. |
| MongoDB authentication failure | Edit the encrypted Vault, rerun the database role, and inspect redacted service logs. |
| React remains on Loading | Check the browser `/trip` request, Nginx proxy, PM2 logs, backend `.env`, and database reachability. |
| Nginx validation failure | Run `sudo nginx -t` and correct the reported site error before reload. |
| PM2 missing after reboot | Check `systemctl status pm2-ubuntu`, rerun the web role, and save the PM2 process list. |
| Destroy dependency error | Keep Terraform state, resolve the exact named dependency, and rerun the destroy workflow. |

## Submission summary

Terraform owns the complete AWS lifecycle and outputs only non-secret connection metadata. Ansible uses that metadata for direct and bastion SSH configuration. React and Express share one public origin through Nginx, while MongoDB remains private and authenticated. The evidence set demonstrates provisioning, configuration, application persistence, hardening, and cleanup. Submit the public GitHub repository link through Vlearn in the requested wrapper format.
