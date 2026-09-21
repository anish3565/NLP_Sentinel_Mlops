output "cluster_name" {
  value = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "s3_dvc_bucket" {
  value = aws_s3_bucket.dvc_remote.bucket
}

output "prometheus_public_ip" {
  value = aws_instance.prometheus.public_ip
}

output "grafana_public_ip" {
  value = aws_instance.grafana.public_ip
}

output "prometheus_url" {
  value = "http://${aws_instance.prometheus.public_ip}:9090"
}

output "grafana_url" {
  value = "http://${aws_instance.grafana.public_ip}:3000"
}
