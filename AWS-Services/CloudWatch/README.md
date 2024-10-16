# EC2 Monitoring with SNS, SQS, and CloudWatch

This script automates the setup of monitoring for an EC2 instance using Amazon SNS (Simple Notification Service), SQS (Simple Queue Service), and CloudWatch. It creates an SNS topic, subscribes an email for notifications, sets up an SQS queue to receive messages, and configures a CloudWatch alarm to monitor network traffic on the specified EC2 instance.

## Prerequisites

- **AWS CLI**: Ensure that the AWS Command Line Interface (CLI) is installed and configured on your machine.
- **IAM Permissions**: The AWS credentials used must have permissions to create and manage the following:
  - SNS topics and subscriptions
  - SQS queues
  - CloudWatch alarms
- **EC2 Instance**: An existing EC2 instance should be running and accessible.

## Setup Instructions

1. **Clone the Repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd <repository-directory>

**How It Works**

1. **SNS Topic:** The script creates an SNS topic for monitoring notifications and subscribes the specified email address to it.

2. **SQS Queue:** An SQS queue is created and subscribed to the SNS topic to receive notifications.

3. **CloudWatch Alarm:** A CloudWatch alarm is configured to monitor the NetworkIn metric of the specified EC2 instance. If the traffic exceeds a defined threshold, a notification is sent to the SNS topic, which is then delivered to the SQS queue.

4. **Message Verification:** The script checks for messages in the SQS queue to verify that notifications are being received.

**Additional Information**

1. **Cost:** Using AWS services may incur charges. Please check the AWS pricing page for details.

2. **Email Subscription Confirmation:** After running the script, you may need to confirm your email subscription through a confirmation link sent to your inbox.

3. **CloudWatch Dashboard:** You can monitor your EC2 instance and CloudWatch alarms in the AWS Management Console under the CloudWatch section.
