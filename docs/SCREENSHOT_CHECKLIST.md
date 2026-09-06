# Assignment Screenshot Checklist

Use readable screenshots, crop unrelated windows, and preserve timestamps where useful. Redact AWS account IDs, access keys, private keys, passwords, vault passwords, MongoDB connection strings, and unrelated browser or terminal content.

| # | Filename | Required proof |
| --- | --- | --- |
| 1 | `01-aws-identity-redacted.png` | Successful `aws sts get-caller-identity`; partially redact account ID. |
| 2 | `02-terraform-validate.png` | Successful Terraform initialization and validation. |
| 3 | `03-terraform-plan-summary.png` | Reviewed plan summary and resource counts. |
| 4 | `04-terraform-apply-output.png` | Successful apply and application/public-IP outputs. |
| 5 | `05-vpc-resource-map.png` | VPC, both subnets, route tables, Internet Gateway, and NAT Gateway. |
| 6 | `06-ec2-instances.png` | Both running instances, subnet placement, and only web public addressing. |
| 7 | `07-security-groups.png` | Restricted web SSH, public HTTP, web-only MongoDB, and bastion SSH rules. |
| 8 | `08-iam-instance-profile.png` | EC2 role/profile and Systems Manager core policy. |
| 9 | `09-ssh-web-server.png` | Successful SSH to the web server. |
| 10 | `10-ssh-private-via-bastion.png` | Successful ProxyJump SSH to the private database host. |
| 11 | `11-ansible-connectivity.png` | Successful Ansible connectivity to both host groups. |
| 12 | `12-ansible-play-recap.png` | First deployment recap with zero failed/unreachable hosts. |
| 13 | `13-ansible-idempotence.png` | Second deployment recap with no unexpected changes. |
| 14 | `14-web-services.png` | Active Nginx and PM2-managed backend. |
| 15 | `15-mongodb-service-auth.png` | Active MongoDB plus authenticated ping; hide credentials. |
| 16 | `16-firewall-status.png` | UFW status and restrictive rules on both hosts. |
| 17 | `17-application-home.png` | TravelMemory home page loaded through the web public IP. |
| 18 | `18-create-memory.png` | Completed add-experience form without sensitive data. |
| 19 | `19-persisted-memory.png` | Newly created record still visible after refresh. |
| 20 | `20-api-success.png` | Successful `/trip` browser request or sanitized curl response. |
| 21 | `21-github-repository.png` | Public repository showing app, Terraform, Ansible, README, and guide. |
| 22 | `22-terraform-destroy.png` | Successful Terraform destruction summary. |
| 23 | `23-cleanup-confirmation.png` | Terminated instances and no NAT Gateway or unattached Elastic IP. |

Commit only screenshots 05, 12, 17, 19, and 22 under `docs/screenshots/` by default. Keep the complete redacted set locally for Vlearn. Never commit unredacted originals.
