#!/bin/bash

# Environmental Variables
BUCKET_1="pavan-bucket-1"
BUCKET_2="pavan-bucket-2"
BUCKET_3="pavan-bucket-3"
REGION="us-west-2"
EC2_INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c55b159cbfafe1f0" 
SUBNET_ID="subnet-xxxxxxxx"  
SECURITY_GROUP_ID="sg-xxxxxxxx" 

# Step 1: Create S3 Buckets
aws s3api create-bucket --bucket $BUCKET_1 --region $REGION --create-bucket-configuration LocationConstraint=$REGION
aws s3api create-bucket --bucket $BUCKET_2 --region $REGION --create-bucket-configuration LocationConstraint=$REGION
aws s3api create-bucket --bucket $BUCKET_3 --region $REGION --create-bucket-configuration LocationConstraint=$REGION

echo "Buckets created: $BUCKET_1, $BUCKET_2, $BUCKET_3"

# Step 2: Upload Files to Buckets
aws s3 cp t1.txt s3://$BUCKET_1/
aws s3 cp t2.txt s3://$BUCKET_1/
aws s3 cp t3.txt s3://$BUCKET_1/

aws s3 cp t4.txt s3://$BUCKET_2/
aws s3 cp t5.txt s3://$BUCKET_2/
aws s3 cp t6.txt s3://$BUCKET_2/

aws s3 cp t7.txt s3://$BUCKET_3/
aws s3 cp t8.txt s3://$BUCKET_3/
aws s3 cp t9.txt s3://$BUCKET_3/

echo "Files uploaded to respective buckets"

# Step 3: Copy Files Between Buckets
aws s3 cp s3://$BUCKET_1/ s3://$BUCKET_2/ --recursive
aws s3 cp s3://$BUCKET_1/ s3://$BUCKET_3/ --recursive

echo "Files copied between buckets"

# Step 4: Configure Static Website Hosting for Bucket-1
aws s3 website s3://$BUCKET_1/ --index-document index.html
aws s3api put-bucket-policy --bucket $BUCKET_1 --policy file://policy.json
aws s3api put-bucket-acl --bucket $BUCKET_1 --acl public-read

echo "Bucket-1 configured as static website"

# Step 5: Create IAM User and Policy
IAM_USER_NAME="my-user"
aws iam create-user --user-name $IAM_USER_NAME

# Create Policy
aws iam create-policy --policy-name MyPolicy --policy-document file://policy.json
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn arn:aws:iam::aws:policy/MyPolicy

echo "IAM user and policy created"

# Step 6: Create EC2 Instance in Private Subnet
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $EC2_INSTANCE_TYPE \
    --key-name $KEY_NAME --subnet-id $SUBNET_ID --security-group-ids $SECURITY_GROUP_ID \
    --associate-public-ip-address

echo "EC2 instance created in private subnet"

# Step 7: Block and Allow IP Addresses
# Create JSON files for bucket policies
cat <<EOL > block_ip_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::$BUCKET_2/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "192.0.2.0/24"  # Replace with the IP address to block
                }
            }
        }
    ]
}
EOL

cat <<EOL > allow_ip_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::$BUCKET_3/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "203.0.113.0/32"  # Replace with the IP address to allow
                }
            }
        }
    ]
}
EOL

aws s3api put-bucket-policy --bucket $BUCKET_2 --policy file://block_ip_policy.json
aws s3api put-bucket-policy --bucket $BUCKET_3 --policy file://allow_ip_policy.json

echo "Blocked and allowed specific IP addresses on buckets"
