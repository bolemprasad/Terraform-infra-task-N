output "instance_ids" {
  description = "Map of instance name => EC2 ID"
  value       = module.ec2_instances.instance_ids
}

output "private_ips" {
  description = "Map of instance name => private IP"
  value       = module.ec2_instances.private_ips
}

output "public_ips" {
  description = "Map of instance name => public IP (null for private-only)"
  value       = module.ec2_instances.public_ips
}
