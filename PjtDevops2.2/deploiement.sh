#!/bin/bash
terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan
rm key.pem
terraform output -raw tls_private_key > key.pem
chmod 400 key.pem 
IPdevOps=`az vm show -d -g RessourcesDevOps -n VmPjt --query publicIps -o tsv`  
IPdevOps2=`az vm show -d -g RessourcesDevOps -n VmPjt2 --query publicIps -o tsv`  
IPdevOps3=`az vm show -d -g RessourcesDevOps -n VmPjt3 --query publicIps -o tsv`  
echo $IPdevOps
echo $IPdevOps2
echo $IPdevOps3
#rm ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
#touch ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
echo "server1 ansible_host=$IPdevOps ansible_user=azureuser ansible_ssh_private_key_file=/home/user/Documents/PjtDevops2.2/key.pem"  > ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt 
echo "server2 ansible_host=$IPdevOps2 ansible_user=azureuser ansible_ssh_private_key_file=/home/user/Documents/PjtDevops2.2/key.pem"  >> ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt 
echo "server3 ansible_host=$IPdevOps3 ansible_user=azureuser ansible_ssh_private_key_file=/home/user/Documents/PjtDevops2.2/key.pem"  >> ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt 
ansible-playbook ansible-playbooks/wordpress-lamp_ubuntu1804/playbook.yml -i ansible-playbooks/wordpress-lamp_ubuntu1804/inventory.txt
echo "************************************************"
echo "your Vm is ready to be used at "$IPdevOps
echo "************************************************"
#home/user/Documents/PjtDevops2.2/ansible-playbooks/wordpress-lamp_ubuntu1804

