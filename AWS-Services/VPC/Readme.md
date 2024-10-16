**AWS VPC Creation Script**

This script automates the creation of an Amazon Virtual Private Cloud (VPC) along with three public and three private subnets in the us-west-2 region. It sets up routing tables, an Internet Gateway, and a NAT Gateway for your AWS infrastructure.

**Table of Contents**

1. Prerequisites
2. Environmental Variables
3. Script Steps
4. Usage
5. License
6. Contact

**Prerequisites**

AWS CLI installed and configured on your machine.

IAM permissions to create VPCs, subnets, route tables, and gateways.


**Environmental Variables**

The following environmental variables are defined in the script:

VPC_CIDR="10.0.0.0/16"

PUBLIC_CIDR_1="10.0.1.0/24"

PUBLIC_CIDR_2="10.0.2.0/24"

PUBLIC_CIDR_3="10.0.3.0/24"

PRIVATE_CIDR_1="10.0.4.0/24"

PRIVATE_CIDR_2="10.0.5.0/24"

PRIVATE_CIDR_3="10.0.6.0/24"

REGION="us-west-2"

**Script Steps**

1. Create VPC: Creates a VPC with the specified CIDR block.

2. Create Subnets: Creates three public and three private subnets across different availability zones.

3. Create Route Tables: Sets up a public route table and a private route table.

4. Create and Attach Internet Gateway: Creates an Internet Gateway and attaches it to the VPC.

5. Add Routes: Adds a route to the public route table for internet access and a route to the private route table via the NAT Gateway.

6. Associate Subnets with Route Tables: Associates public subnets with the public route table and private subnets with the private route table.

7. Create NAT Gateway: Allocates an Elastic IP and creates a NAT Gateway in one of the public subnets.

8. Add Route to Private Route Table via NAT Gateway: Configures the private route table to route internet-bound traffic through the NAT Gateway.

9. Associate Private Subnets to Private Route Table: Associates all private subnets with the private route table.
