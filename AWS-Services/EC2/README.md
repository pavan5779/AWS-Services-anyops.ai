# **EC2 Management Script**

This Bash script automates the management of Amazon EC2 instances, including launching instances in public and private subnets, creating snapshots, modifying volumes, and installing Java packages based on the operating system.

## **Table of Contents**

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Steps](#script-steps)
- [How to Connect to EC2 Instances](#how-to-connect-to-ec2-instances)
- [License](#license)

## **Prerequisites**

Before running this script, ensure you have the following:

- AWS CLI installed and configured with appropriate permissions.
- Access to the specified AWS region (`us-west-2` and `ap-south-1`).
- A valid EC2 key pair (`MyKeyPair`).
- Valid subnet IDs for both public and private subnets.

## **Usage**

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/ec2-management-script.git
   cd ec2-management-script


**Script Steps**

Launch EC2 Instance in Public Subnet: Creates an EC2 instance in a public subnet and associates a public IP address.

Launch EC2 Instance in Private Subnet: Creates an EC2 instance in a private subnet.

Stop EC2 Instances: Stops the created EC2 instances.

Create an EC2 Instance with 8 GB Storage: Launches a new instance with a specified EBS volume size.

Create a Snapshot: Creates a snapshot of the EBS volume attached to the instance.

Extend Storage: Modifies the EBS volume to increase its size.

Delete the Snapshot: Deletes the snapshot created earlier.

Connect to EC2 Instances: Instructions on connecting to the instances if the PEM key is lost.

Create Instances in Different Availability Zones: Creates two instances in different subnets.

Stop and Detach EBS Volume: Stops one instance, detaches its EBS volume, and attaches it to another instance.

Retrieve Private IP Addresses: Fetches the private IP addresses of running instances and saves them to a file.

Install Java Packages: Creates a script to install Java based on the operating system of each instance.
