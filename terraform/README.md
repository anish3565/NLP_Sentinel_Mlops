# Terraform for NLP Sentinel MLOps

Infrastructure-as-code version of the manually-provisioned stack behind
[NLP_Sentinel_Mlops](https://github.com/anish3565/NLP_Sentinel_Mlops):
VPC, EKS cluster + node group, ECR repository, S3 bucket for DVC, and
two EC2 instances for Prometheus/Grafana.

## What this creates

| Resource | Purpose | Approx. cost while running |
|---|---|---|
| EKS control plane | Kubernetes API for the Flask app | **$0.10/hr flat — always, no free tier** |
| 1x t3.small node | Runs the Flask pod | ~$0.02/hr (region-dependent) |
| 2x t3.micro (Prometheus/Grafana) | Monitoring | Free tier eligible (750 hrs/month combined, first 12 months) |
| ECR repo | Docker image storage | Negligible (~$0.10/GB/month) |
| S3 bucket | DVC remote | Negligible for small datasets |
| VPC (public subnets only, no NAT) | Networking | $0 — this is why there's no NAT Gateway |

Rough total while the cluster is up: **~$0.15–0.20/hour**, or about
**$3.60–4.80** for a full 24-hour test window if you forget to tear it
down. That's the number the budget alert below protects you from.

## First-time setup

1. Install Terraform (>=1.5) and the AWS CLI
2. `aws configure` with the `terraform-deployer` IAM user's keys
3. `cp terraform.tfvars.example terraform.tfvars` and fill in your IP
   (`curl ifconfig.me`) and email
4. `terraform init`

## Workflow

```bash
terraform plan      # review what will be created — always do this first
terraform apply      # spin everything up
# ... do your testing, deploy the Flask app, check Prometheus/Grafana ...
./destroy.sh          # tear down safely, in the right order
```

After `apply`, connect kubectl:

```bash
$(terraform output -raw configure_kubectl)
kubectl apply -f ../k8s/deployment.yaml   # from the main repo
```

## Teardown — do not skip this

Run `./destroy.sh` rather than `terraform destroy` directly — it
deletes any Kubernetes `LoadBalancer` Service first. Those create a
real AWS load balancer that Terraform never sees, so a bare
`terraform destroy` leaves it running and billing.

The script ends with a manual checklist (Load Balancers, Elastic IPs,
EBS volumes, Cost Explorer) — walk through it every time. Budgets/CloudWatch
alarms are your backstop if something still slips through.

## Notes on the choices made here

- **No NAT Gateway.** Worker nodes sit in public subnets with public
  IPs instead of a private-subnet + NAT setup. Saves ~$32-40/month.
  Not how you'd do this in production — call that out if it comes up
  in an interview.
- **Local Terraform state**, not an S3 backend. One less resource to
  track and delete for a solo test project.
- **`force_delete` / `force_destroy`** set on the ECR repo and S3
  bucket so `terraform destroy` doesn't get stuck on non-empty
  resources.
- **`cluster_version`** is pinned explicitly — an EKS cluster left on
  an unsupported version gets silently moved to extended support at
  6x the control-plane price. Check the EKS release calendar before
  each apply if you reuse this later.
