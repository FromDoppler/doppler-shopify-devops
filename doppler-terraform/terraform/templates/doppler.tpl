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
  - source /etc/environment
  - instanceid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-')
  - hostn=$(cat /etc/hostname)
  - newhostn="${environment}-${role}-$instanceid"
  - echo "Existing hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostname $newhostn
  - service rsyslog restart
  - /usr/local/bin/aws s3 cp s3://doppler-shopify/backup/${environment}/doppler.sql /tmp/doppler.sql
  - mysql < /tmp/doppler.sql
  - mysql -e "CREATE USER 'doppler'@'%' IDENTIFIED BY 'yT0bH8mP0uV0xP2q'; GRANT ALL ON doppler.* TO 'doppler'@'%';"
  - /usr/local/bin/aws s3 cp s3://doppler-shopify/artifacts/${environment}/latest.tar.gz /var/www/html/latest.tar.gz
  - mkdir -p /var/www/html/doppler-shopify && tar zxvf /var/www/html/latest.tar.gz -C /var/www/html/doppler-shopify
  - chown -R www-data:www-data /var/www/html/doppler-shopify
  - cd /var/www/html/doppler-shopify/ && composer install
  - aws ssm get-parameter --name shopify-${environment}-env --region us-east-2 --with-decryption | jq .Parameter.Value > /var/www/html/doppler-shopify/.env
  - sed -i '0,/"/{s/"//}' /var/www/html/doppler-shopify/.env && sed -i 's/\(.*\)"/\1 /' /var/www/html/doppler-shopify/.env
  - sed -i 's/\\n/\n/g' /var/www/html/doppler-shopify/.env && sed -i 's/=\\/=/' /var/www/html/doppler-shopify/.env
  - sed -i 's/-\\/-/' /var/www/html/doppler-shopify/.env
  - php /var/www/html/doppler-shopify/artisan migrate --no-interaction
  - if [ "${environment}" = "prd" ]; then sed -i "s/SRVNAME/sfyapp.fromdoppler.com/" /etc/apache2/sites-enabled/doppler-shopify.conf ; fi
  - if [ "${environment}" != "prd" ]; then sed -i "s/SRVNAME/sfyapp-${environment}.fromdoppler.net/" /etc/apache2/sites-enabled/doppler-shopify.conf ; fi
  - systemctl reload apache2