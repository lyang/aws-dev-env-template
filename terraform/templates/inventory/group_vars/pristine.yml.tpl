---
ansible_user: ${ec2-user}
ansible_connection: ssh
ansible_ssh_private_key_file: ${ec2-user-private-key}
admin_public_key: ${admin-public-key}
ebs: ${device-name}