#!/bin/bash

# Environmental Variables
VPC_CIDR="10.0.0.0/16"
PUBLIC_CIDR_1="10.0.1.0/24"
PUBLIC_CIDR_2="10.0.2.0/24"
PUBLIC_CIDR_3="10.0.3.0/24"
PRIVATE_CIDR_1="10.0.4.0/24"
PRIVATE_CIDR_2="10.0.5.0/24"
PRIVATE_CIDR_3="10.0.6.0/24"
REGION="us-west-2"

# Step 1: Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text --region $REGION)
echo "VPC created with ID: $VPC_ID"

# Step 2: Create Subnets (3 public, 3 private)
PUBLIC_SUBNET_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_CIDR_1 --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
PUBLIC_SUBNET_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_CIDR_2 --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)
PUBLIC_SUBNET_3=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_CIDR_3 --availability-zone ${REGION}c --query 'Subnet.SubnetId' --output text)

PRIVATE_SUBNET_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_CIDR_1 --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
PRIVATE_SUBNET_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_CIDR_2 --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)
PRIVATE_SUBNET_3=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_CIDR_3 --availability-zone ${REGION}c --query 'Subnet.SubnetId' --output text)

echo "Public subnets created: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2, $PUBLIC_SUBNET_3"
echo "Private subnets created: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2, $PRIVATE_SUBNET_3"

# Step 3: Create Route Tables
PUBLIC_ROUTE_TABLE=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text --region $REGION)
PRIVATE_ROUTE_TABLE=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text --region $REGION)
echo "Public Route Table: $PUBLIC_ROUTE_TABLE, Private Route Table: $PRIVATE_ROUTE_TABLE"

# Step 4: Create IGW and Attach to VPC
IGW=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text --region $REGION)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW --region $REGION
echo "Internet Gateway: $IGW attached to VPC"

# Step 5: Add Routes
aws ec2 create-route --route-table-id $PUBLIC_ROUTE_TABLE --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW --region $REGION
echo "Route added to public route table via IGW"

# Step 6: Associate Subnets with Route Tables
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_1 --route-table-id $PUBLIC_ROUTE_TABLE --region $REGION
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_2 --route-table-id $PUBLIC_ROUTE_TABLE --region $REGION
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_3 --route-table-id $PUBLIC_ROUTE_TABLE --region $REGION

echo "All public subnets associated with the public route table"

# Step 7: Create NAT Gateway
EIP=$(aws ec2 allocate-address --query 'AllocationId' --output text --region $REGION)
NAT_GW=$(aws ec2 create-nat-gateway --subnet-id $PUBLIC_SUBNET_1 --allocation-id $EIP --query 'NatGateway.NatGatewayId' --output text --region $REGION)
echo "NAT Gateway created with Elastic IP: $EIP and NAT GW: $NAT_GW"

# Step 8: Add Route to Private Route Table via NAT Gateway
aws ec2 create-route --route-table-id $PRIVATE_ROUTE_TABLE --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW --region $REGION
echo "Route to Private Route Table via NAT Gateway added"

# Step 9: Associate Private Subnets to Private Route Table
aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_1 --route-table-id $PRIVATE_ROUTE_TABLE --region $REGION
aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_2 --route-table-id $PRIVATE_ROUTE_TABLE --region $REGION
aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_3 --route-table-id $PRIVATE_ROUTE_TABLE --region $REGION

echo "All private subnets associated with the private route table"
