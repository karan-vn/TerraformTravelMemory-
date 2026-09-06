param(
  [string]$TerraformDirectory = "../terraform",
  [string]$PrivateKeyPath = "~/.ssh/travelmemory_ed25519",
  [string]$OutputPath = "../ansible/inventory/hosts.yml"
)

$ErrorActionPreference = "Stop"
$tf = terraform -chdir=$TerraformDirectory output -json | ConvertFrom-Json
$webIp = $tf.web_public_ip.value
$webPrivateIp = $tf.web_private_ip.value
$databaseIp = $tf.database_private_ip.value
$operatorCidr = $tf.operator_cidr.value
$publicSubnetCidr = $tf.public_subnet_cidr.value
$inventory = @"
all:
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: $PrivateKeyPath
    operator_cidr: $operatorCidr
    public_subnet_cidr: $publicSubnetCidr
  children:
    web:
      hosts:
        web1:
          ansible_host: $webIp
          private_ip: $webPrivateIp
    database:
      hosts:
        database1:
          ansible_host: $databaseIp
          ansible_ssh_common_args: '-o ProxyJump=ubuntu@$webIp'
"@

$destination = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot $OutputPath))
New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
[System.IO.File]::WriteAllText($destination, $inventory, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote Ansible inventory to $destination"
