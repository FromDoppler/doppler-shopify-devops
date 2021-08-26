#!/bin/bash
set -eux
sleep 30
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install python3-pip python-dev libffi-dev libssl-dev git -y
sudo pip install --upgrade pip
sudo pip install pyOpenSSL==16.2.0
sudo pip install ansible==2.9
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts
