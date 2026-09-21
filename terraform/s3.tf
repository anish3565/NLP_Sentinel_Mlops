resource "random_id" "bucket_suffix" {
  byte_length = 4 # S3 bucket names must be globally unique
}

resource "aws_s3_bucket" "dvc_remote" {
  bucket = "${var.project_name}-dvc-${random_id.bucket_suffix.hex}"

  # Lets `terraform destroy` delete the bucket even if it still has
  # objects (DVC-tracked data) inside it.
  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "dvc_remote" {
  bucket = aws_s3_bucket.dvc_remote.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
