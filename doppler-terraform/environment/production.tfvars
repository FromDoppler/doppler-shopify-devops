# TF statment
tf_bucket                       = "doppler-tf-states"

account                         = "288672893446"
environment                     = "production"
environment_code                = "prd"
az                              = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
iam_role                        = "doppler-shopify"
private_subnets_cidr            = [ "10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24" ]

# VPC
aws_region                      = "us-east-2"

# ASG
asg_enabled_metrics = []
role          = "siab"
isntance_type = "t3.micro"
asg_desired_capacity = 1
asg_min_size = 1
asg_max_size = 1
asg_check_type = "ELB"

doppler_ssl_arn = "arn:aws:acm:us-east-2:288672893446:certificate/ac984044-df05-4840-9456-07e3140ad9dc"