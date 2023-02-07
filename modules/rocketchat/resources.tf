data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["${var.aws_ami_name}"]
  }

  filter {
    name   = "architecture"
    values = ["${var.aws_ami_architecture}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.aws_ami_virtualization}"]
  }

}

data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

resource "tls_private_key" "instance_public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_key_pair" {
  key_name   = local.instance_key_name
  public_key = tls_private_key.instance_public_key.public_key_openssh

  provisioner "local-exec" {
    when    = create
    command = "echo '${tls_private_key.instance_public_key.private_key_pem}' > ./'${self.key_name}'.pem && chmod 400 ./'${self.key_name}'.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./'${self.key_name}'.pem"
  }

  tags = {
    Name = local.instance_key_name
  }
}

resource "aws_security_group" "allow_ssh_https_http" {
  name        = local.security_group_name
  description = "Allow TLS, HTTPS, and HTTP traffic from Anywhere"

  tags = {
    Name = local.security_group_name
  }

  ingress {
    description = "Allow SSH traffic from Anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPs traffic from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RocketChat Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "RocketChat Outgoing Port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "chat_instance" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.instance_key_pair.key_name
  security_groups             = ["${aws_security_group.allow_ssh_https_http.name}"]
  disable_api_termination     = false
  associate_public_ip_address = true
  user_data                   = file("./modules/rocketchat/setup-instance.sh")

  tags = {
    Name = local.instance_name
  }

}

resource "aws_eip" "chat_eip" {
  vpc = true
}

resource "aws_eip_association" "chat_eip_association" {
  instance_id   = aws_instance.chat_instance.id
  allocation_id = aws_eip.chat_eip.id
}

resource "aws_route53_record" "chat_url" {
  name    = local.chat_url
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.chat_eip.public_ip}"]
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_s3_bucket" "chat_bucket" {
  bucket = local.s3_bucket_name
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["${local.chat_url}", "houseworksinc.co"]
    max_age_seconds = 3000
  }
}


