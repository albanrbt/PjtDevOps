#IPdevOps=`az vm show -d -g RessourcesDevOps -n VmPjt --query publicIps -o tsv`  
IpdevOps=2
echo "server1 ansible_host=$IpdevOps ansible_user=azureuser ansible_ssh_private_key_file=/home/user/Documents/PjtDevops2.0/key.pem" 

