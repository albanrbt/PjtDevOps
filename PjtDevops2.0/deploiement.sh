#!/bin/bash
terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan
rm key.pem
terraform output -raw tls_private_key > key.pem
chmod 400 key.pem 
IPdevOps=`az vm show -d -g RessourcesDevOps -n VmPjt --query publicIps -o tsv`  
echo $IPdevOps
rm ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
touch ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
echo "server1 ansible_host=$IPdevOps ansible_user=azureuser ansible_ssh_private_key_file=/home/user/Documents/PjtDevops2.0/key.pem"  > ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt 
ansible-playbook ansible-playbooks/wordpress-lamp_ubuntu1804/playbook.yml -i ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
echo "************************************************"
echo "your Vm is ready to be used at "$IPdevOps
echo "************************************************"
#home/user/Documents/PjtDevops2.0/ansible-playbooks/wordpress-lamp_ubuntu1804

