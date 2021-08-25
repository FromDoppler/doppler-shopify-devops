## EC2 for Shopify

#########################################################
# Instance Profiles

resource "aws_iam_instance_profile" "iam_siab_servers_profile" {
  name  = "iam_siab_servers_profile_${var.environment}"
  role = data.terraform_remote_state.iam.outputs.siab_servers_role_name
}

#########################################################
# AutoScaling Groups

# Servicedesk User Data
data "template_file" "doppler_userdata" {
  template = file("../../terraform/templates/doppler.tpl")

  vars = {
    region = var.aws_region
    environment = var.environment
    role = var.role
  }
}

# Shopify AutoScaling Group
module "app_asg" {
    source = "../../terraform/modules/autoscaling_group"

    lc_instance_role        = "siab"
    lc_name_prefix          = "${var.environment_code}-doppler-shopify-lc"
    lc_instance_type        = var.isntance_type
    lc_ebs_optimized        = "false"
    lc_key_name             = data.terraform_remote_state.vpc.outputs.main_key_name
    lc_security_groups      = concat([ aws_security_group.doppler_security_group.id ])
    lc_iam_instance_profile = aws_iam_instance_profile.iam_siab_servers_profile.id
    lc_user_data            = data.template_file.doppler_userdata.rendered

    asg_name                = "${var.environment_code}-doppler-shopify-asg"
    asg_subnet_ids          = data.terraform_remote_state.vpc.outputs.public_subnet_ids
    asg_desired_capacity    = var.asg_desired_capacity
    asg_min_size            = var.asg_min_size
    asg_max_size            = var.asg_max_size
    asg_target_groups      = [ aws_lb_target_group.https_tg.arn, aws_lb_target_group.http_tg.arn ]
    asg_check_type          = var.asg_check_type
    asg_enabled_metrics     = var.asg_enabled_metrics
    asg_name_tag = "${var.environment_code}-doppler-shopify-asg"

    asg_policy = "${var.environment_code}-doppler-shopify-asg"

    instance_name_tag = "${var.environment_code}-doppler-shopify"
    instance_role_tag = "app"
    tags = local.common_tags
    environment = var.environment
}
