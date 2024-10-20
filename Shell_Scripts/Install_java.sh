#!/bin/bash

# Read instance IPs from the file
while IFS= read -r line; do
    # Extract Instance ID and Private IP
    instance_id=$(echo $line | awk '{print $1}')
    private_ip=$(echo $line | awk '{print $2}')

    echo "Connecting to Instance ID: $instance_id with IP: $private_ip"

    # Try detecting Red Hat/CentOS
    echo "Checking OS for Red Hat/CentOS..."
    os=$(ssh -q -o StrictHostKeyChecking=no -i /mnt/e/PAVAN/Projects/VPC/pradeep.pem ec2-user@$private_ip "cat /etc/redhat-release 2>/dev/null")
    echo "OS detection output: $os"

    if [[ $os == *"Red Hat"* || $os == *"CentOS"* ]]; then
        echo "Detected Red Hat/CentOS OS"
        ssh -q -o StrictHostKeyChecking=no -i /mnt/e/PAVAN/Projects/VPC/pradeep.pem ec2-user@$private_ip "sudo yum update -y && sudo yum install -y java-11-openjdk"
    else
        # Try detecting Ubuntu
        echo "Checking OS for Ubuntu..."
        os=$(ssh -q -o StrictHostKeyChecking=no -i /mnt/e/PAVAN/Projects/VPC/pradeep.pem ubuntu@$private_ip "lsb_release -d 2>/dev/null")
        echo "OS detection output: $os"

        if [[ $os == *"Ubuntu"* ]]; then
            echo "Detected Ubuntu OS"
            ssh -q -o StrictHostKeyChecking=no -i /mnt/e/PAVAN/Projects/VPC/pradeep.pem ubuntu@$private_ip "sudo apt-get update && sudo apt-get install -y openjdk-11-jdk"
        else
            echo "Unknown OS for Instance ID: $instance_id"
        fi
    fi
done < "instance_ips.txt"
