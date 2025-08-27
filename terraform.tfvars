aws_region = "eu-west-1"

key_name        = "my-keypair"
public_key_path = "keys/my-keypair.pub"

office_cidrs          = ["203.0.113.10/32"] # your office/VPN IP/CIDR
allow_db_from_bastion = true

instance_map = {
  bastion = {
    ami                 = "ami-xxxxxxxxxxxxxxxxx" # Windows Server AMI in your region
    instance_type       = "t3.medium"
    subnet_id           = "********"
    vpc_id              = "*******"
    associate_public_ip = true
    tags                = { Role = "bastion", OS = "windows", Env = "dev" }
  }

  mongodb = {
    ami           = "ami-xxxx" # Ubuntu 22.04 AMI
    instance_type = "t3.small"
    subnet_id     = "subnet-private-bbbbbbb"
    vpc_id        = "******"
    tags          = { Role = "mongodb", OS = "ubuntu", Env = "dev" }
  }

  redis = {
    ami           = "Change AMI" # Ubuntu 22.04 AMI
    instance_type = "t3.small"
    subnet_id     = "********"
    vpc_id        = "******"
    tags          = { Role = "redis", OS = "ubuntu", Env = "dev" }
  }
}
