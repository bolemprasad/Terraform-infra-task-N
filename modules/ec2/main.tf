locals {
  normalized = {
    for name, cfg in var.instance_map :
    name => merge(
      {
        associate_public_ip = false
        tags                = {}
      },
      cfg
    )
  }

  bastion_only = {
    for name, cfg in local.normalized :
    name => cfg if name == "bastion"
  }

  mongodb_only = {
    for name, cfg in local.normalized :
    name => cfg if name == "mongodb"
  }

  redis_only = {
    for name, cfg in local.normalized :
    name => cfg if name == "redis"
  }
}

# ---------- Security Groups (split per role) ----------

# Bastion SG (in bastion's VPC)
resource "aws_security_group" "bastion" {
  for_each    = local.bastion_only
  name        = "${each.key}-sg"
  description = "Bastion SG (RDP/SSH from office/VPN)"
  vpc_id      = each.value.vpc_id

  # RDP 3389 from office/VPN
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.office_cidrs
    description = "RDP from office/VPN"
  }

  # SSH 22 from office/VPN (optional but harmless)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.office_cidrs
    description = "SSH from office/VPN"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${each.key}-sg" }, each.value.tags)
}

# MongoDB SG (in mongo's VPC) — allows 27017 (+ optional SSH) from bastion SG
resource "aws_security_group" "mongodb" {
  for_each    = local.mongodb_only
  name        = "${each.key}-sg"
  description = "MongoDB SG (27017 from bastion)"
  vpc_id      = each.value.vpc_id

  # MongoDB from bastion
  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion["bastion"].id]
    description     = "MongoDB from bastion"
  }

  # Optional: SSH 22 from bastion for admin
  dynamic "ingress" {
    for_each = var.allow_db_from_bastion ? [1] : []
    content {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion["bastion"].id]
      description     = "SSH from bastion (admin)"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${each.key}-sg" }, each.value.tags)
}

# Redis SG (in redis' VPC) — allows 6379 (+ optional SSH) from bastion SG
resource "aws_security_group" "redis" {
  for_each    = local.redis_only
  name        = "${each.key}-sg"
  description = "Redis SG (6379 from bastion)"
  vpc_id      = each.value.vpc_id

  # Redis from bastion
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion["bastion"].id]
    description     = "Redis from bastion"
  }

  # Optional: SSH 22 from bastion for admin
  dynamic "ingress" {
    for_each = var.allow_db_from_bastion ? [1] : []
    content {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion["bastion"].id]
      description     = "SSH from bastion (admin)"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${each.key}-sg" }, each.value.tags)
}

# ---------- EC2 Instances ----------

resource "aws_instance" "this" {
  for_each = local.normalized

  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  key_name      = var.key_name

  # Attach the SG created for the matching role
  vpc_security_group_ids = (
    each.key == "bastion" ? [aws_security_group.bastion["bastion"].id] :
    each.key == "mongodb" ? [aws_security_group.mongodb["mongodb"].id] :
    each.key == "redis"   ? [aws_security_group.redis["redis"].id] :
    []
  )

  associate_public_ip_address = try(each.value.associate_public_ip, false)

  tags = merge(
    { Name = each.key },
    each.value.tags
  )
}
