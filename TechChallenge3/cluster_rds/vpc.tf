data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "eks-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow inbound traffic from any IP address.
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

    egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Retrieve the Auto Scaling Group associated with the EKS nodes
data "aws_autoscaling_groups" "eks_node_groups" {
  filter {
    name   = "tag:KubernetesCluster"
    values = [var.cluster_name]
  }
}

# Extract security group IDs from the Auto Scaling Group
locals {
  node_group_security_groups = [
    for asg in data.aws_autoscaling_groups.eks_node_groups.names : asg.launch_template[0].security_group_names
  ]
}

# Flatten the list of security group IDs
locals {
  flattened_security_groups = flatten(local.node_group_security_groups)
}

# Allow inbound traffic from the EKS node groups to the RDS instance
resource "aws_security_group_rule" "allow_eks_nodes_to_rds" {
  for_each = toset(local.flattened_security_groups)

  type              = "ingress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "allow_eks_nodes" {
  for_each = toset(local.flattened_security_groups)

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = each.value
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "private_subnets_ids" {
  value = module.vpc.private_subnets
}