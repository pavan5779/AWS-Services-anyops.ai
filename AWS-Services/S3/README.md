# AWS S3 and EC2 Management Script

This script automates the creation and management of AWS S3 buckets and EC2 instances using the AWS Command Line Interface (CLI). It covers the following tasks:

1. Create S3 buckets.
2. Upload files to the S3 buckets.
3. Copy files between S3 buckets.
4. Configure static website hosting for one of the buckets.
5. Create an IAM user and policy.
6. Create an EC2 instance in a private subnet.
7. Manage IP address permissions for S3 buckets.

## Prerequisites

- **AWS CLI:** Ensure that the AWS CLI is installed and configured on your system. You can follow the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- **AWS Account:** You need an active AWS account with appropriate permissions to create S3 buckets, EC2 instances, IAM users, and policies.
- **Required Files:** Ensure that the following files are present in the same directory as the script:
  - `t1.txt`, `t2.txt`, `t3.txt`, `t4.txt`, `t5.txt`, `t6.txt`, `t7.txt`, `t8.txt`, `t9.txt` (files to upload).
  - `policy.json` (IAM policy document for the user).

## Configuration

Before running the script, update the following variables in the script:

- **`REGION`:** The AWS region where the resources will be created (e.g., `ap-south-1`).
- **`EC2_INSTANCE_TYPE`:** The type of EC2 instance to launch (e.g., `t2.micro`).
- **`AMI_ID`:** A valid Amazon Machine Image (AMI) ID for your region.
- **`KEY_NAME`:** The name of your existing EC2 key pair.
- **`SUBNET_ID`:** The ID of the private subnet where the EC2 instance will be launched.
- **`SECURITY_GROUP_ID`:** The ID of the security group to associate with the EC2 instance.

## Usage

1. Clone this repository or download the script file.
2. Open a terminal and navigate to the directory where the script is located.
3. Run the script using the following command:

   ```bash
   chmod +x script.sh  # Make the script executable
   ./script.sh          # Execute the script
