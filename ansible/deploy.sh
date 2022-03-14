#!/bin/bash

# Wait for cloud-init on first boot
echo "Checking if cloud-init is finished..."
until [ -f /home/azadmin/cloudinit_finished ]
do
     sleep 5
done
echo "Cloud-init tasks finished successfully!"

# Install Ansible collections
echo "Installing needed Ansible collections"
ansible-galaxy install -r requirements.yaml

# K8s cluster
echo "Deploying k8s cluster..."
ansible-playbook -i hosts deploy-k8s.yaml
echo "K8s cluster deployed successfully..."

# NFS
echo "Deploying NFS server..."
ansible-playbook -i hosts deploy-nfs.yaml
echo "NFS server deployed successfully..."

#Nginx
echo "Deploying Nginx HTTP server..."
ansible-playbook -i hosts deploy-nginx.yaml
echo "Nginx deployed successfully..."

# Wait for Nginx to be up
echo "Waiting for Nginx to be up..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' -H 'Host: foo.bar' http://10.0.1.10:30372/nginx/)" != "200" ]];
do sleep 5;
done

echo ""
curl -H 'Host: foo.bar' http://10.0.1.10:30372/nginx/
echo ""


echo "Nginx is up. Check it up yourself with the following command:"
echo "curl -H 'Host: foo.bar' http://10.0.1.10:30372/nginx/"
