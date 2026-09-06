const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const read = (relativePath) => fs.readFileSync(path.join(root, relativePath), 'utf8');

test('Terraform defines the assignment network and two EC2 instances', () => {
  const networking = read('terraform/networking.tf');
  const compute = read('terraform/compute.tf');

  for (const resource of ['aws_vpc', 'aws_subnet', 'aws_internet_gateway', 'aws_nat_gateway', 'aws_route_table']) {
    assert.match(networking, new RegExp(`resource "${resource}"`));
  }
  assert.match(compute, /resource "aws_instance" "web"/);
  assert.match(compute, /resource "aws_instance" "database"/);
  assert.match(compute, /associate_public_ip_address\s*=\s*false/);
});

test('Terraform restricts operator SSH and MongoDB network access', () => {
  const variables = read('terraform/variables.tf');
  const security = read('terraform/security.tf');

  assert.match(variables, /operator_cidr/);
  assert.match(variables, /var\.operator_cidr != "0\.0\.0\.0\/0"/);
  assert.match(security, /from_port\s*=\s*22/);
  assert.match(security, /cidr_ipv4\s*=\s*var\.operator_cidr/);
  assert.match(security, /from_port\s*=\s*27017/);
  assert.match(security, /referenced_security_group_id\s*=\s*aws_security_group\.web\.id/);
});

test('Ansible deploys authenticated private MongoDB and production web services', () => {
  const site = read('ansible/site.yml');
  const mongo = read('ansible/roles/mongodb/tasks/main.yml');
  const mongoConfig = read('ansible/roles/mongodb/templates/mongod.conf.j2');
  const mongoRepository = read('ansible/roles/mongodb/templates/mongodb-org-7.0.list.j2');
  const web = read('ansible/roles/web/tasks/main.yml');
  const nginx = read('ansible/roles/web/templates/travelmemory.conf.j2');

  assert.match(site, /role:\s*mongodb/);
  assert.match(site, /role:\s*web/);
  assert.match(mongoConfig, /authorization:\s*enabled/);
  assert.match(mongoRepository, /mongodb\.org\/apt/);
  assert.match(web, /npm ci/);
  assert.match(web, /package-lock\.sha256/);
  assert.match(web, /when: frontend_source\.changed or frontend_environment\.changed or frontend_dependencies\.changed/);
  assert.match(web, /pm2/);
  assert.match(nginx, /proxy_pass http:\/\/127\.0\.0\.1:3001/);
  assert.match(nginx, /try_files \$uri \$uri\/ \/index\.html/);
});

test('inventory generator emits a bastion-aware database host', () => {
  const generator = read('scripts/generate-inventory.ps1');
  const outputs = read('terraform/outputs.tf');
  const commonRole = read('ansible/roles/common/tasks/main.yml');

  assert.match(generator, /terraform .*output -json/);
  assert.match(generator, /ansible_ssh_common_args/);
  assert.match(generator, /ProxyJump/);
  assert.match(outputs, /output "web_private_ip"/);
  assert.match(generator, /private_ip/);
  assert.match(commonRole, /hostvars\[groups\['web'\]\[0\]\]\.private_ip/);
});

test('documentation and evidence checklist cover deployment and cleanup', () => {
  const readme = read('README.md');
  const guide = read('docs/EXECUTION_GUIDE.md');
  const checklist = read('docs/SCREENSHOT_CHECKLIST.md');

  assert.match(readme, /Terraform/);
  assert.match(readme, /Ansible/);
  assert.match(readme, /terraform destroy/);
  assert.match(guide, /WSL2/);
  assert.match(guide, /ansible-vault/);
  assert.match(guide, /terraform destroy/);
  assert.match(checklist, /01-aws-identity-redacted\.png/);
  assert.match(checklist, /23-cleanup-confirmation\.png/);
});

test('gitignore excludes infrastructure state and secrets', () => {
  const gitignore = read('.gitignore');

  for (const ignored of ['*.tfstate', '.terraform/', 'terraform.tfvars', 'vault.yml', '.vault-pass', 'ansible/inventory/hosts.yml']) {
    assert.ok(gitignore.includes(ignored), `missing ignore rule: ${ignored}`);
  }
});
