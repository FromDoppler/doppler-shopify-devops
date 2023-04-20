# TF statment
tf_bucket                       = "doppler-tf-states"

account                         = "288672893446"
environment                     = "qa"
environment_code                = "qa"
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

doppler_ssl_arn = "arn:aws:acm:us-east-2:288672893446:certificate/fb9511ff-8c1b-434e-a58b-136d4f747285"

## SSH Access for dev and admins
admin_access_cidr   = [ "190.16.38.64/32",       # Federico Aguirre VNS
                        "190.105.118.48/32",     # Adrián Aguirre VNS
                        "181.46.166.218/32",     # Adrián Catacora
                        "200.5.229.58/32",       # doppler VPN1
                        "200.5.253.210/32",      # doppler VPN2
                        "104.131.79.81/32",      # doppler jenkins
                        "159.89.34.79/32"        # doppler new jenkins
                    ]