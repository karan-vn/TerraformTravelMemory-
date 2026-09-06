resource "aws_security_group" "web" {
  name        = "${var.project_name}-web"
  description = "Public HTTP and operator-only SSH"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project_name}-web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "Public HTTP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from the operator only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.operator_cidr
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "Private MongoDB and bastion SSH"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project_name}-database-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "database_mongodb" {
  security_group_id            = aws_security_group.database.id
  description                  = "MongoDB from the web server"
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "database_ssh" {
  security_group_id = aws_security_group.database.id
  description       = "SSH forwarded by the public-subnet bastion"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.public_subnet_cidr
}

resource "aws_vpc_security_group_egress_rule" "database_all" {
  security_group_id = aws_security_group.database.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
