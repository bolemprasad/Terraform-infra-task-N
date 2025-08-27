Terraform AWS Bastion + MongoDB + Redis

This project provisions a bastion host (Windows) in a public subnet and two Ubuntu EC2 instances (MongoDB & Redis) in private subnets, using Terraform modules.
The design ensures that private resources are only accessible through the bastion host.



Architecture Overview

Bastion Host (Windows)

Deployed in a public VPC/subnet

Accessible only from whitelisted office_cidrs via RDP (3389) or SSH (22)

Used as a secure jump box to reach private resources

MongoDB (Ubuntu)

Runs in a private subnet

No public IP

Accepts traffic on 27017 only from the bastion

Redis (Ubuntu)

Runs in a private subnet

No public IP

Accepts traffic on 6379 only from the bastion

Security Groups are automatically created and linked per role.

Key Pair is created from your local public key (.pub file in repo).





Prerequisites

Terraform
 >= 1.4

AWS CLI configured with credentials

Pre-existing VPCs & Subnets:

One public VPC/subnet (for bastion)

One private VPC/subnets (for MongoDB and Redis)

A valid SSH key pair (.pub file placed in ./keys/)


Accessing the Instances

Bastion (Windows)

Get Windows password from EC2 console → Get Windows Password → upload private key (my-keypair).

Connect via RDP to bastion_public_ip:3389.

MongoDB / Redis (private)

Reachable only from bastion.

Option 1: Install client tools on bastion and connect internally.

Option 2: Use SSH tunneling via bastion:

# MongoDB tunnel
ssh -i keys/my-keypair -L 27017:<mongo_private_ip>:27017 Administrator@<bastion_public_ip>

# Redis tunnel
ssh -i keys/my-keypair -L 6379:<redis_private_ip>:6379 Administrator@<bastion_public_ip>



