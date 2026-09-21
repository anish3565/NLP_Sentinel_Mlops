variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1" # Mumbai — lowest latency from India
}

variable "project_name" {
  description = "Tag applied to every resource, used to find/audit everything later"
  type        = string
  default     = "nlp-sentinel-test"
}

variable "environment" {
  description = "Environment name (test/dev) — this stack is not meant for production use"
  type        = string
  default     = "test"
}

# ---------------- EKS ----------------

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "nlp-sentinel-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version. Keep this on a version still in STANDARD support — an expired version silently moves to extended support at 6x the control-plane price ($0.60/hr instead of $0.10/hr). Check the current EKS release calendar before applying."
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Number of worker nodes. Keep at 1 for testing — this is billed as normal EC2 on top of the flat $0.10/hr EKS control-plane fee."
  type        = number
  default     = 1
}

# ---------------- Networking ----------------

variable "allowed_ssh_cidr" {
  description = "Your IP in CIDR form (e.g. 203.0.113.4/32) — used to restrict SSH and monitoring ports instead of opening them to the world. Find yours with `curl ifconfig.me`."
  type        = string
}

# ---------------- EC2 monitoring (Prometheus/Grafana) ----------------

variable "monitoring_instance_type" {
  description = "Instance type for the Prometheus/Grafana EC2 boxes"
  type        = string
  default     = "t3.micro" # free-tier eligible, unlike t3.small
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH access to monitoring instances. Leave null to skip SSH access entirely (you can still reach Grafana/Prometheus over HTTP)."
  type        = string
  default     = null
}

# ---------------- Cost safety net ----------------

variable "enable_budget_alert" {
  description = "Create an AWS Budget that emails you if spend crosses the threshold. Strongly recommended — leave true unless your account already has one."
  type        = bool
  default     = true
}

variable "budget_limit_usd" {
  description = "Monthly budget ceiling in USD that triggers the alert email"
  type        = string
  default     = "5"
}

variable "alert_email" {
  description = "Email address for budget alerts. Required if enable_budget_alert is true."
  type        = string
  default     = ""
}
