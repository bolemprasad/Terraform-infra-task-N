Terraform AWS Bastion + MongoDB + Redis
This project provisions a Bastion Host (Windows) in a public subnet and two Ubuntu EC2 instances (MongoDB & Redis) in private subnets, using Terraform modules. The design ensures that private resources are only accessible through the bastion host.
Architecture Overview
Bastion Host (Windows)
- Deployed in a public VPC/subnet
- Accessible only from whitelisted office_cidrs
- Protocols allowed: RDP (3389), SSH (22)
- Serves as a secure jump box to reach private resources
MongoDB (Ubuntu)
- Runs in a private subnet
- No public IP
- Accepts traffic on 27017 only from the bastion
Redis (Ubuntu)
- Runs in a private subnet
- No public IP
- Accepts traffic on 6379 only from the bastion
Security Groups
- Automatically created and linked per role
- Bastion SG: Allows inbound RDP/SSH from office_cidrs
- MongoDB SG: Allows 27017 only from Bastion
- Redis SG: Allows 6379 only from Bastion
Key Pair
- Created from your local public key (.pub) placed in ./keys/
Prerequisites
- Terraform >= 1.4
- AWS CLI configured with credentials
- Pre-existing VPCs & Subnets:
  * One public VPC/subnet (for bastion)
  * One private VPC/subnets (for MongoDB and Redis)
- A valid SSH key pair (.pub file placed in ./keys/)
Accessing the Instances
Bastion (Windows)
1. Go to EC2 Console → select Bastion instance → Get Windows Password
2. Upload your private key (my-keypair)
3. Copy the decrypted Administrator password
4. RDP into Bastion: bastion_public_ip:3389
MongoDB / Redis (Private)
Reachable only from bastion.

Option 1: Install client tools on bastion and connect internally.

Option 2: Use SSH tunneling via bastion:
# MongoDB tunnel
ssh -i keys/my-keypair -L 27017:<mongo_private_ip>:27017 Administrator@<bastion_public_ip>

# Redis tunnel
ssh -i keys/my-keypair -L 6379:<redis_private_ip>:6379 Administrator@<bastion_public_ip>
