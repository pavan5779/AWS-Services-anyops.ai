#!/bin/bash

# AWS CLI Script to Automate VPC, Subnet, Route Table, IGW, NGW, and EC2 Instance Setup

# 1. Create a VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
echo "VPC ID '$VPC_ID' created."

# 2. Create 6 Subnets (3 Public, 3 Private)
echo "Creating subnets..."
PUBLIC_SUBNET_IDS=()
PRIVATE_SUBNET_IDS=()
for i in {1..3}; do
    PUBLIC_SUBNET_IDS+=($(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.$i.0/24 --availability-zone ap-south-1a --query 'Subnet.SubnetId' --output text))
    PRIVATE_SUBNET_IDS+=($(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.$((i+3)).0/24 --availability-zone ap-south-1a --query 'Subnet.SubnetId' --output text))
done
echo "Public subnets created: ${PUBLIC_SUBNET_IDS[@]}"
echo "Private subnets created: ${PRIVATE_SUBNET_IDS[@]}"

# 3. Create Public and Private Route Tables
echo "Creating route tables..."
PUBLIC_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
PRIVATE_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Public Route Table ID: $PUBLIC_RT_ID"
echo "Private Route Table ID: $PRIVATE_RT_ID"

# 4. Create Internet Gateway (IGW)
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
echo "Internet Gateway ID '$IGW_ID' created."

# 5. Attach IGW to VPC
echo "Attaching Internet Gateway to VPC..."
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

# 6. Add Route to Public Route Table (to send traffic via IGW)
echo "Adding route to Public Route Table..."
aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# 7. Associate all 3 Public Subnets to Public Route Table
echo "Associating public subnets with Public Route Table..."
for SUBNET_ID in ${PUBLIC_SUBNET_IDS[@]}; do
    aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $SUBNET_ID
done

# 8. Create NAT Gateway (NGW) along with Elastic IP
echo "Creating NAT Gateway and Elastic IP..."
EIP_ALLOC_ID=$(aws ec2 allocate-address --query 'AllocationId' --output text)
NGW_ID=$(aws ec2 create-nat-gateway --subnet-id ${PUBLIC_SUBNET_IDS[0]} --allocation-id $EIP_ALLOC_ID --query 'NatGateway.NatGatewayId' --output text)
echo "NAT Gateway ID '$NGW_ID' created."

# Wait for NAT Gateway to become available
echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NGW_ID
echo "NAT Gateway is now available."

# 9. Add Route to Private Route Table (to send traffic via NGW)
echo "Adding route to Private Route Table..."
aws ec2 create-route --route-table-id $PRIVATE_RT_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NGW_ID

# 10. Associate all 3 Private Subnets to Private Route Table
echo "Associating private subnets with Private Route Table..."
for SUBNET_ID in ${PRIVATE_SUBNET_IDS[@]}; do
    aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $SUBNET_ID
done
