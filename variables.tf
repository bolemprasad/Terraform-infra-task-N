variable "aws_region" {
  description = "AWS region (e.g., eu-west-1)"
  type        = string
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "public_key_path" {
  description = "Path to your public key file (relative to repo is best)"
  type        = string
}

variable "instance_map" {
  description = "Map of EC2 instances to create"
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_id           = string
    vpc_id              = string
    associate_public_ip = optional(bool, false)
    tags                = optional(map(string), {})
  }))
}

variable "office_cidrs" {
  description = "CIDRs allowed to reach bastion (RDP/SSH)"
  type        = list(string)
  default     = []
}

variable "allow_db_from_bastion" {
  description = "Allow DB ports (Redis/Mongo) from bastion for admin"
  type        = bool
  default     = true
}
