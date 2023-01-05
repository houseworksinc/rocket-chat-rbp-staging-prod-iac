module "backend" {
  source  = "./modules/backend"
  region  = var.aws_region
  project = "${var.project_name}-chat"
}

module "rocketchat" {
  source                 = "./modules/rocketchat"
  region                 = var.aws_region
  project_name           = var.project_name
  environment            = var.environment
  domain_name            = var.domain_name
  chat_sub_domain        = var.chat_sub_domain
  lets_encrypt_email     = var.lets_encrypt_email
  ec2_instance_type      = var.ec2_instance_type
  aws_ami_name           = var.aws_ami_name
  aws_ami_architecture   = var.aws_ami_architecture
  aws_ami_virtualization = var.aws_ami_virtualization
}