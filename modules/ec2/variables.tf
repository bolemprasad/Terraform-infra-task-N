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

variable "key_name" {
  type        = string
  description = "Key pair to attach to instances"
}

variable "office_cidrs" {
  description = "CIDRs allowed into bastion (3389/22)"
  type        = list(string)
  default     = []
}

variable "allow_db_from_bastion" {
  description = "Allow DB ports (Redis 6379, Mongo 27017) from bastion"
  type        = bool
  default     = true
}
