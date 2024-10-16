#!/bin/bash

# Environmental Variables
USER_A="UserA"
USER_B="UserB"
USER_C="UserC"
GROUP_NAME="Developers"
POLICY_S3_READ_ONLY="S3ReadOnlyAccess"
POLICY_EC2_FULL_ACCESS="EC2FullAccess"
POLICY_S3_EC2_LIST_ONLY="S3EC2ListOnly"

# Step 1: Create IAM Group
aws iam create-group --group-name $GROUP_NAME
echo "IAM Group $GROUP_NAME created"

# Step 2: Create IAM Users
aws iam create-user --user-name $USER_A
aws iam create-user --user-name $USER_B
aws iam create-user --user-name $USER_C
echo "IAM Users $USER_A, $USER_B, $USER_C created"

# Step 3: Set UserA to require password change on first login
aws iam create-login-profile --user-name $USER_A --password 'TemporaryPassword123!' --password-reset-required
echo "User $USER_A created with password change required on first login"

# Step 4: Create and Attach S3 Read-Only Policy to Developers Group
aws iam create-policy --policy-name $POLICY_S3_READ_ONLY --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:GetObject","Resource":"*"}]}'
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/$POLICY_S3_READ_ONLY
echo "S3 Read-Only policy attached to $GROUP_NAME"

# Step 5: Attach Policies to Users
# UserB - EC2 Full Access and S3 Full Access
aws iam create-policy --policy-name $POLICY_EC2_FULL_ACCESS --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["ec2:*","s3:*"],"Resource":"*"}]}'
aws iam attach-user-policy --user-name $USER_B --policy-arn arn:aws:iam::aws:policy/$POLICY_EC2_FULL_ACCESS
echo "User $USER_B has EC2 and S3 full access"

# UserC - List Only S3 and EC2
aws iam create-policy --policy-name $POLICY_S3_EC2_LIST_ONLY --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:ListBucket","ec2:DescribeInstances"],"Resource":"*"}]}'
aws iam attach-user-policy --user-name $USER_C --policy-arn arn:aws:iam::aws:policy/$POLICY_S3_EC2_LIST_ONLY
echo "User $USER_C has list-only access to S3 and EC2"

# Step 6: Create Access Keys for Users
aws iam create-access-key --user-name $USER_A > UserA_Keys.json
aws iam create-access-key --user-name $USER_B > UserB_Keys.json
aws iam create-access-key --user-name $USER_C > UserC_Keys.json
echo "Access keys created for $USER_A, $USER_B, and $USER_C"

# Step 7: Instructions for configuring AWS CLI
echo "To configure AWS CLI on your local machine, use the following commands:"
echo "1. Open your terminal (or command prompt)."
echo "2. Run the command: aws configure"
echo "3. When prompted, enter the Access Key ID and Secret Access Key from the respective User_Keys.json file."
echo "4. Enter the default region name and output format."

# Completion message
echo "All tasks completed successfully!"
