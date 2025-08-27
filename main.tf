# 1) Key pair (reads the .pub file from your repo)
module "keypair" {
  source          = "./modules/keypair"
  key_name        = var.key_name
  public_key_path = var.public_key_path
}

# 2) EC2 instances + auto-wired security groups
module "ec2_instances" {
  source       = "./modules/ec2"
  key_name     = module.keypair.key_name
  instance_map = var.instance_map

  office_cidrs          = var.office_cidrs
  allow_db_from_bastion = var.allow_db_from_bastion
}
