#!/bin/bash

# 11. Launch an EC2 Instance in Public Subnet
echo "Launching EC2 instance in public subnet..."
PUBLIC_INSTANCE_ID=$(aws ec2 run-instances --image-id ami-05134c8ef96964280 --instance-type t2.micro --key-name pradeep --subnet-id ${PUBLIC_SUBNET_IDS[0]} --query 'Instances[0].InstanceId' --output text)
echo "EC2 Instance ID '$PUBLIC_INSTANCE_ID' launched in public subnet."

# 12. Launch an EC2 Instance in Private Subnet
echo "Launching EC2 instance in private subnet..."
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances --image-id ami-05134c8ef96964280 --instance-type t2.micro --key-name pradeep --subnet-id ${PRIVATE_SUBNET_IDS[0]} --query 'Instances[0].InstanceId' --output text)
echo "EC2 Instance ID '$PRIVATE_INSTANCE_ID' launched in private subnet."

# 13. Connect to EC2 Instance in Public Subnet
echo "You can connect to your EC2 instance in the public subnet using SSH."

# 14. Connect to EC2 Instance in Private Subnet
echo "To connect to your EC2 instance in the private subnet, use the public instance as a jump server."

# 15. Stop Both EC2 Instances
echo "Stopping both EC2 instances..."
aws ec2 stop-instances --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID

# 16. Create an EC2 Instance with 8 GB Storage
echo "Launching a new EC2 instance with 8 GB storage..."
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-05134c8ef96964280 --instance-type t2.micro --key-name pradeep --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":8}}]" --query 'Instances[0].InstanceId' --output text)
echo "New EC2 Instance ID '$INSTANCE_ID' launched with 8 GB storage."

# 17. Create a Snapshot for the EC2 Instance's EBS Volume
echo "Creating a snapshot of the EC2 instance's EBS volume..."
VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' --output text)
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --description "Snapshot of volume $VOLUME_ID" --query 'SnapshotId' --output text)
echo "Snapshot ID '$SNAPSHOT_ID' created."

# 18. Extend Storage by an Additional 8 GB for the Running Instance
echo "Extending storage of the running instance by an additional 8 GB..."
aws ec2 modify-volume --volume-id $VOLUME_ID --size 16
echo "Volume ID '$VOLUME_ID' extended to 16 GB."

# 19. Delete the Snapshot Created Earlier
echo "Deleting the snapshot..."
aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
echo "Snapshot ID '$SNAPSHOT_ID' deleted."

# 20. Instructions on How to Connect to an EC2 Instance if the PEM Key is Lost
echo "To connect to an EC2 instance if the PEM key is lost, you can either:"
echo "- Use EC2 Instance Connect (browser-based SSH)."
echo "- Create an AMI from the instance, launch a new instance, and set a new key pair."
echo "- Attach the root volume to another instance to modify the authorized_keys file."

# 21. Create Instance-1 in ap-south-1a with an 8 GB Volume
echo "Launching EC2 instance-1 in ap-south-1a with 8 GB volume..."
INSTANCE_1_ID=$(aws ec2 run-instances --image-id ami-05134c8ef96964280 --instance-type t2.micro --key-name pradeep --subnet-id ${PUBLIC_SUBNET_IDS[0]} --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":8}}]" --query 'Instances[0].InstanceId' --output text)
echo "Instance-1 ID '$INSTANCE_1_ID' launched in ap-south-1a."

# 22. Create Instance-2 in ap-south-1b with an 8 GB Volume
echo "Launching EC2 instance-2 in ap-south-1b with 8 GB volume..."
INSTANCE_2_ID=$(aws ec2 run-instances --image-id ami-05134c8ef96964280 --instance-type t2.micro --key-name pradeep --subnet-id ${PUBLIC_SUBNET_IDS[1]} --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":8}}]" --query 'Instances[0].InstanceId' --output text)
echo "Instance-2 ID '$INSTANCE_2_ID' launched in ap-south-1b."

# 23. Stop and Detach the EBS Volume from Instance-1 and Attempt to Attach it to Instance-2
echo "Stopping instance-1 and detaching its EBS volume..."
aws ec2 stop-instances --instance-ids $INSTANCE_1_ID
aws ec2 wait instance-stopped --instance-ids $INSTANCE_1_ID

VOLUME_ID_1=$(aws ec2 describe-instances --instance-ids $INSTANCE_1_ID --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' --output text)
aws ec2 detach-volume --volume-id $VOLUME_ID_1
aws ec2 wait volume-available --volume-ids $VOLUME_ID_1

echo "Attempting to attach EBS volume from instance-1 to instance-2..."
aws ec2 attach-volume --volume-id $VOLUME_ID_1 --instance-id $INSTANCE_2_ID --device /dev/sdf

echo "Note: Attaching an EBS volume from one instance to another is possible if both instances are in the same availability zone and the volume is of a supported type (e.g., gp2, io1, st1, etc.). If the volume is not attachable, you may need to create a snapshot and then create a new volume from the snapshot in the desired AZ."

echo "Script execution completed."

