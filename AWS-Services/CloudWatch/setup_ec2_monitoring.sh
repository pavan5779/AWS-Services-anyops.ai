#!/bin/bash

# Environmental Variables
TOPIC_NAME="EC2Monitoring"
EMAIL="pavankalyanmeda5779@gmail.com"
REGION="us-west-2"
INSTANCE_ID="i-0ab5ee386515e9f3c"
QUEUE_NAME="EC2MonitoringQueue"

# Step 1: Create SNS Topic and Subscribe Email
echo "Creating SNS Topic..."
TOPIC_ARN=$(aws sns create-topic --name "$TOPIC_NAME" --query 'TopicArn' --output text --region "$REGION")
aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol email --notification-endpoint "$EMAIL" --region "$REGION"
echo "SNS Topic created and subscribed with email: $EMAIL"

# Step 2: Create SQS Queue and Subscribe it to SNS Topic
echo "Creating SQS Queue..."
QUEUE_URL=$(aws sqs create-queue --queue-name "$QUEUE_NAME" --query 'QueueUrl' --output text --region "$REGION")
aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol sqs --notification-endpoint "$QUEUE_URL" --region "$REGION"
echo "SQS Queue created and subscribed to SNS Topic."

# Step 3: Create CloudWatch Alarm
echo "Creating CloudWatch Alarm for EC2 instance: $INSTANCE_ID..."
aws cloudwatch put-metric-alarm \
  --alarm-name NetworkInAlarm \
  --metric-name NetworkIn \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 100000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --evaluation-periods 1 \
  --alarm-actions "$TOPIC_ARN" \
  --unit Bytes \
  --region "$REGION"
echo "CloudWatch alarm created for EC2 instance: $INSTANCE_ID"

# Step 4: Verify Message Delivery from SQS
echo "Verifying messages in SQS Queue..."
RECEIVE_MESSAGE_OUTPUT=$(aws sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 10 --wait-time-seconds 10 --region "$REGION")
if [ -z "$RECEIVE_MESSAGE_OUTPUT" ]; then
  echo "No messages in SQS Queue."
else
  echo "Messages received from SQS Queue:"
  echo "$RECEIVE_MESSAGE_OUTPUT"
fi

# Optional: Print out Queue URL and Topic ARN
echo "SNS Topic ARN: $TOPIC_ARN"
echo "SQS Queue URL: $QUEUE_URL"
