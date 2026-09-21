# Reminder: the EKS control plane bills at a flat $0.10/hr the moment
# this resource exists — regardless of whether any node or pod is
# running. Only `terraform apply` this when you're actively testing,
# and `terraform destroy` (see README) as soon as you're done.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets # see vpc.tf for why public-only

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 1
      desired_size = var.node_desired_size

      # Nodes need public IPs since they're in public subnets with no NAT
      subnet_ids = module.vpc.public_subnets
    }
  }

  # Gives your IAM user cluster-admin via kubectl automatically
  enable_cluster_creator_admin_permissions = true

  tags = local.common_tags
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}
