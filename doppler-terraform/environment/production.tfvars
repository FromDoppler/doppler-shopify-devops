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
isntance_type = "t3.medium"
asg_desired_capacity = 1
asg_min_size = 1
asg_max_size = 1
asg_check_type = "ELB"

doppler_ssl_arn = "arn:aws:acm:us-east-2:288672893446:certificate/d0273f67-be0c-47bf-9131-833a376b85b1"

## SSH Access for dev and admins
admin_access_cidr   = [ "190.16.38.64/32",       # Federico Aguirre VNS
                        "190.105.118.48/32",     # Adrián Aguirre VNS
                        "181.44.131.56/32",      # Adrián Catacora
                        "181.170.106.169/32",    # Federico Aguirre VNS 
                        "200.5.229.58/32",       # doppler VPN1
                        "200.5.253.210/32",      # doppler VPN2
                        "159.89.34.79/32"        # doppler jenkins
                    ]