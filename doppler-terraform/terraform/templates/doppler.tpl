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
  - /home/deployer sudo mysql < /tmp/doppler.sql
  - /home/deployer sudo mysql -e "CREATE USER 'doppler'@'%' IDENTIFIED BY 'yT0bH8mP0uV0xP2q'; GRANT ALL ON doppler.* TO 'doppler'@'%';"
  - /usr/local/bin/aws s3 cp s3://doppler-shopify/artifacts/$ENVIRONMENT/latest.tar.gz /var/www/html/latest.tar.gz
  - tar zxvf /var/www/html/latest.tar.gz -C /var/www/html/
  - chown -R www-data:www-data /var/www/html/doppler-shopify\
  - php /var/www/html/doppler-shopify/artisan migrate\
  - if [ "${environment}" = "prd" ]; then sed -i "s/SRVNAME/sfyapp.fromdoppler.com/" /etc/apache2/sites-enabled/doppler-shopify.conf \ 
    else [ "${environment}" != "prd" ]; then sed -i "s/SRVNAME/sfyapp-${environment}.fromdoppler.net/" /etc/apache2/sites-enabled/doppler-shopify.conf fi
