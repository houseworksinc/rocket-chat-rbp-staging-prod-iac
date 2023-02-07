locals {
  chat_url = "${var.chat_sub_domain}.${var.environment}.${var.project_name}.${var.domain_name}"
}

locals {
  instance_key_name = "${var.environment}-${var.project_name}-chat-ec2-key"
}

locals {
  instance_name = "${var.environment}-${var.project_name}-chat"
}

locals {
  security_group_name = "${var.environment}-${var.project_name}-chat-sec-grp"
}

locals {
  s3_bucket_name = "${var.environment}-${var.project_name}-chat-bucket"
}
