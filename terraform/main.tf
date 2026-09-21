terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Local state on purpose for a solo test project — one less resource
  # (S3 bucket + DynamoDB lock table) to remember to clean up.
  # Switch to an S3 backend later if this becomes a shared/team project.
}

provider "aws" {
  region = var.aws_region
  profile = "terraform-deployer"


  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    AutoDestroy = "true"
  }
}
