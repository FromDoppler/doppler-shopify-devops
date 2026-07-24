#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive
sleep 30
sudo apt-get update
sudo apt-get install python3-pip python3-dev git -y
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install pyOpenSSL
sudo python3 -m pip install 'ansible>=2.9,<2.10'
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts
