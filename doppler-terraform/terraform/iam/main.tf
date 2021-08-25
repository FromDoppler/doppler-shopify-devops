# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# IAM Roles
## Roles and Policies

resource "aws_iam_role" "siab_servers_role" {
  name = "siab_servers_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "siab_servers_policy" {
  name = "siab_servers_policy"
  role = aws_iam_role.siab_servers_role.id
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject",
            "cloudwatch:PutMetricData",
            "SNS:Publish",
            "ec2:DescribeVolumes",
            "ec2:DescribeTags"
         ],
         "Resource":"*"
      }
   ]
}
EOF
}
