#cloud-config
environment:
environment:
  environment: ${environment}
  role: ${role}
  aws_region: ${region}
preserve_hostname: true
runcmd:
  - set -x
  - export HOME=/root
  - echo "ENVIRONMENT=${environment}" >> /etc/environment
  - instanceid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-')
  - hostn=$(cat /etc/hostname)
  - newhostn="${environment}-${role}-$instanceid"
  - echo "Existing hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostname $newhostn
  - service rsyslog restart
  - /usr/local/bin/aws s3 cp s3://doppler-shopify/backup/$ENVIRONMENT/doppler.sql /tmp/doppler.sql
  - /usr/local/bin/aws s3 cp s3://doppler-shopify/artifacts/$ENVIRONMENT/doppler.tar.gz /tmp/doppler.tar.gz
  - /home/deployer mysql -u root -p root < /tmp/doppler.sql
  - if [ "${environment}" = "prd" ]; then sed -i "s/SRVNAME/sfyapp.fromdoppler.com/" /etc/apache2/sites-enabled/doppler-shopify.conf \ 
    else [ "${environment}" != "prd" ]; then sed -i "s/SRVNAME/sfyapp-${environment}.fromdoppler.net/" /etc/apache2/sites-enabled/doppler-shopify.conf fi
