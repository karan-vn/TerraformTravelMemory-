resource "aws_key_pair" "operator" {
  key_name   = "${var.project_name}-operator"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.operator.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true
  monitoring                  = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = { Name = "${var.project_name}-web" }
}

resource "aws_instance" "database" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.database_instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.database.id]
  key_name                    = aws_key_pair.operator.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = false
  monitoring                  = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = { Name = "${var.project_name}-database" }
}
