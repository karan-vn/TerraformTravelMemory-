output "web_public_ip" {
  description = "Public IPv4 address of the web server."
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS name of the web server."
  value       = aws_instance.web.public_dns
}

output "web_private_ip" {
  description = "Private IPv4 address used for web-to-database traffic."
  value       = aws_instance.web.private_ip
}

output "database_private_ip" {
  description = "Private IPv4 address of the database server."
  value       = aws_instance.database.private_ip
}

output "application_url" {
  description = "URL of the TravelMemory application."
  value       = "http://${aws_instance.web.public_ip}"
}

output "operator_cidr" {
  description = "Operator CIDR used by the SSH rules."
  value       = var.operator_cidr
}

output "public_subnet_cidr" {
  description = "Public-subnet CIDR used for bastion SSH."
  value       = var.public_subnet_cidr
}
