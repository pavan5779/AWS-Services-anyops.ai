#!/bin/bash

# Environmental Variables
IMAGE_ID="ami-05134c8ef96964280"
INSTANCE_TYPE="t2.micro"
KEY_NAME="MyKeyPair"
SUBNET_ID_PUBLIC="subnet-abc123"
SUBNET_ID_PRIVATE="subnet-def456"
REGION="us-west-2"

# Step 1: Launch EC2 Instance in Public Subnet
INSTANCE_ID_PUBLIC=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET_ID_PUBLIC --associate-public-ip-address --key-name $KEY_NAME --region $REGION --query 'Instances[0].InstanceId' --output text)
echo "EC2 instance launched in public subnet with Instance ID: $INSTANCE_ID_PUBLIC"

# Step 2: Launch EC2 Instance in Private Subnet
INSTANCE_ID_PRIVATE=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET_ID_PRIVATE --key-name $KEY_NAME --region $REGION --query 'Instances[0].InstanceId' --output text)
echo "EC2 instance launched in private subnet with Instance ID: $INSTANCE_ID_PRIVATE"

# Step 3: Connect to EC2 Instance in Public Subnet
echo "Connecting to public EC2 instance..."
ssh -i "$KEY_NAME.pem" ec2-user@$INSTANCE_ID_PUBLIC

# Step 4: Connect to EC2 Instance in Private Subnet via Public Instance
echo "Connecting to private EC2 instance via public instance..."
ssh -i "$KEY_NAME.pem" ec2-user@$INSTANCE_ID_PUBLIC -t "ssh ec2-user@$INSTANCE_ID_PRIVATE"

# Step 5: Stop EC2 Instances
aws ec2 stop-instances --instance-ids $INSTANCE_ID_PUBLIC $INSTANCE_ID_PRIVATE --region $REGION
echo "Stopped EC2 instances: $INSTANCE_ID_PUBLIC, $INSTANCE_ID_PRIVATE"

# Step 6: Create an EC2 instance with 8 GB storage
INSTANCE_ID_STORAGE=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --block-device-mappings "DeviceName=/dev/xvda,Ebs={VolumeSize=8}" --key-name $KEY_NAME --region $REGION --query 'Instances[0].InstanceId' --output text)
echo "EC2 instance created with 8 GB storage, Instance ID: $INSTANCE_ID_STORAGE"

# Step 7: Create a Snapshot for the EC2 Instance's EBS Volume
VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID_STORAGE --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' --output text --region $REGION)
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --description "Snapshot of EBS volume" --query 'SnapshotId' --output text --region $REGION)
echo "Snapshot created with ID: $SNAPSHOT_ID"

# Step 8: Extend storage by an additional 8 GB
aws ec2 modify-volume --volume-id $VOLUME_ID --size 16 --region $REGION
echo "Extended EBS volume size by 8 GB"

# Step 9: Delete the snapshot created earlier
aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID --region $REGION
echo "Deleted the snapshot with ID: $SNAPSHOT_ID"

# Step 10: Instructions on how to connect to an EC2 instance if the PEM key is lost
echo "To connect to an EC2 instance if the PEM key is lost:"
echo "1. Stop the instance."
echo "2. Detach the root EBS volume and attach it to another instance."
echo "3. Modify the SSH configuration by injecting a new SSH key."
echo "4. Reattach the volume to the original instance and start it."

# Step 11: Create Instance-1 in ap-south-1a with an 8 GB volume
INSTANCE_ID_INSTANCE1=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --block-device-mappings "DeviceName=/dev/xvda,Ebs={VolumeSize=8}" --key-name $KEY_NAME --subnet-id subnet-1a --region ap-south-1 --query 'Instances[0].InstanceId' --output text)
echo "Instance-1 created in ap-south-1a with ID: $INSTANCE_ID_INSTANCE1"

# Step 12: Create Instance-2 in ap-south-1b with an 8 GB volume
INSTANCE_ID_INSTANCE2=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --block-device-mappings "DeviceName=/dev/xvda,Ebs={VolumeSize=8}" --key-name $KEY_NAME --subnet-id subnet-1b --region ap-south-1 --query 'Instances[0].InstanceId' --output text)
echo "Instance-2 created in ap-south-1b with ID: $INSTANCE_ID_INSTANCE2"

# Step 13: Stop and detach the EBS volume from Instance-1 and attach it to Instance-2
aws ec2 stop-instances --instance-ids $INSTANCE_ID_INSTANCE1 --region ap-south-1
aws ec2 detach-volume --volume-id $VOLUME_ID --region ap-south-1
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID_INSTANCE2 --device /dev/sdf --region ap-south-1
echo "Detached EBS volume from Instance-1 and attached it to Instance-2"

# Step 14: Retrieve the list of private IP addresses of running instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId, PrivateIpAddress]" --output table --region $REGION > instance_ips.txt
echo "Retrieved private IP addresses of running instances and saved to instance_ips.txt"

# Step 15: Create a script to install Java packages based on OS
echo '#!/bin/bash' > install_java.sh
echo 'for ip in $(awk "{print \$2}" instance_ips.txt); do' >> install_java.sh
echo '  OS=$(ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$ip "uname -a")' >> install_java.sh
echo '  if [[ $OS == *"Ubuntu"* ]]; then' >> install_java.sh
echo '    ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$ip "sudo apt update && sudo apt install default-jdk -y"' >> install_java.sh
echo '  elif [[ $OS == *"Red Hat"* ]]; then' >> install_java.sh
echo '    ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$ip "sudo yum update && sudo yum install java-1.8.0-openjdk-devel -y"' >> install_java.sh
echo '  elif [[ $OS == *"CentOS"* ]]; then' >> install_java.sh
echo '    ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$ip "sudo yum update && sudo yum install java-1.8.0-openjdk-devel -y"' >> install_java.sh
echo '  fi' >> install_java.sh
echo 'done' >> install_java.sh
chmod +x install_java.sh
echo "Script to install Java packages created based on OS"

