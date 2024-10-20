#!/bin/bash

# Define variables
PROFILE="default"
REGION="us-west-2"

# Get a list of all instances
INSTANCES=$(aws ec2 describe-instances \
  --profile $PROFILE \
  --region $REGION \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

# Function to stop all running instances
stop_instances() {
  RUNNING_INSTANCES=$(aws ec2 describe-instances \
    --profile $PROFILE \
    --region $REGION \
    --query "Reservations[*].Instances[*].[InstanceId, State.Name]" \
    --output text | grep running | awk '{print $1}')

  if [ -n "$RUNNING_INSTANCES" ]; then
    echo "Stopping instances: $RUNNING_INSTANCES"
    aws ec2 stop-instances --instance-ids $RUNNING_INSTANCES --profile $PROFILE --region $REGION
  else
    echo "No running instances found."
  fi
}

# Function to start all stopped instances
start_instances() {
  STOPPED_INSTANCES=$(aws ec2 describe-instances \
    --profile $PROFILE \
    --region $REGION \
    --query "Reservations[*].Instances[*].[InstanceId, State.Name]" \
    --output text | grep stopped | awk '{print $1}')

  if [ -n "$STOPPED_INSTANCES" ]; then
    echo "Starting instances: $STOPPED_INSTANCES"
    aws ec2 start-instances --instance-ids $STOPPED_INSTANCES --profile $PROFILE --region $REGION
  else
    echo "No stopped instances found."
  fi
}

# Check the time of day and take action
CURRENT_HOUR=$(date +"%H")

if [ "$CURRENT_HOUR" -eq "10" ]; then
  start_instances
elif [ "$CURRENT_HOUR" -eq "19" ]; then
  stop_instances
else
  echo "This script should only run at 10 AM or 7 PM."
fi
