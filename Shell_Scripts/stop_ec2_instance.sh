#!/bin/bash

# Define variables
PROFILE="default"
REGION="us-west-2"
INSTANCE_NAME="us-west-2b-8-GB"

# Get the list of running instances and filter by instance name
RUNNING_INSTANCES=$(aws ec2 describe-instances \
  --profile $PROFILE \
  --region $REGION \
  --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0], State.Name]" \
  --output text | grep running | grep $INSTANCE_NAME)

# Check if the instance exists and stop it
if [ -n "$RUNNING_INSTANCES" ]; then
  INSTANCE_ID=$(echo $RUNNING_INSTANCES | awk '{print $1}')
  echo "Stopping instance $INSTANCE_NAME with ID $INSTANCE_ID"
  aws ec2 stop-instances --instance-ids $INSTANCE_ID --profile $PROFILE --region $REGION
else
  echo "Instance $INSTANCE_NAME not found or not running."
fi
