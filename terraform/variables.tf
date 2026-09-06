variable "aws_region" {
  description = "AWS region in which to deploy the assignment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used for tags and resource names."
  type        = string
  default     = "travelmemory-aws-iac"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private database subnet."
  type        = string
  default     = "10.20.2.0/24"
}

variable "web_instance_type" {
  description = "EC2 instance type for the web server."
  type        = string
  default     = "t3.micro"
}

variable "database_instance_type" {
  description = "EC2 instance type for the database server."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Path to an existing local SSH public key."
  type        = string
}

variable "operator_cidr" {
  description = "Operator public IPv4 address as a /32 CIDR."
  type        = string

  validation {
    condition     = can(cidrhost(var.operator_cidr, 0)) && var.operator_cidr != "0.0.0.0/0" && tonumber(split("/", var.operator_cidr)[1]) == 32
    error_message = "operator_cidr must be one IPv4 /32 address and cannot be 0.0.0.0/0."
  }
}
