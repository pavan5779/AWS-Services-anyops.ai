# IAM User Management Script

## Overview
This script automates the creation of AWS IAM users, groups, and policies. It sets up a group named "Developers" and creates three IAM users (UserA, UserB, UserC) with specified permissions, including S3 read-only access and EC2 full access. It also generates access keys for each user and provides instructions for configuring the AWS CLI.

## Prerequisites
- An AWS account with sufficient permissions to create IAM users, groups, and policies.
- AWS CLI installed and configured on your local machine.
- Bash shell environment for executing the script.

## Script Functionality
1. Creates an IAM group named "Developers."
2. Creates three IAM users: UserA, UserB, UserC.
3. Sets a temporary password for UserA, requiring a password change on first login.
4. Creates and attaches the following IAM policies:
   - S3 Read-Only access for the Developers group.
   - EC2 and S3 Full access for UserB.
   - List-only access to S3 and EC2 for UserC.
5. Generates access keys for each user and saves them in JSON files.
6. Provides instructions for configuring AWS CLI using the generated access keys.

## Usage
1. Clone the repository or download the script file.
2. Open a terminal and navigate to the directory containing the script.
3. Run the script using the following command:

   chmod +x iam_user_management.sh
   ./iam_user_management.sh
