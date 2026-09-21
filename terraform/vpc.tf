# Cost decision: this VPC uses ONLY public subnets, with no NAT Gateway.
# A NAT Gateway costs ~$0.045/hr PLUS per-GB data processing — roughly
# $32-40/month even sitting idle. For a short-lived test cluster that's
# torn down after each session, that's not worth it.
#
# Trade-off: EKS worker nodes get public IPs and pull images (from ECR/
# DockerHub) directly over the internet instead of through a NAT Gateway.
# This is fine for a personal test project; it is NOT the pattern you'd
# use for a real production cluster, where nodes normally sit in private
# subnets behind a NAT Gateway. Mention this trade-off explicitly if it
# comes up in an interview — it shows you understand *why* the default
# differs from best practice, not that you don't know the best practice.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway       = false
  enable_dns_hostnames     = true
  enable_dns_support       = true
  map_public_ip_on_launch  = true

  # Tags required for EKS to auto-discover subnets for load balancers
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  tags = local.common_tags
}
