#!/usr/bin/env bash
# Safe teardown for the nlp-sentinel-test stack.
# Order matters: Kubernetes-created resources (LoadBalancer Services)
# are NOT tracked by Terraform and must be deleted first, or they
# orphan and keep billing after `terraform destroy` finishes.
set -euo pipefail

echo "== Step 1: checking for LoadBalancer-type Kubernetes Services =="
if kubectl get svc --all-namespaces 2>/dev/null | grep -q LoadBalancer; then
  echo "Found LoadBalancer service(s) — deleting before Terraform destroy:"
  kubectl get svc --all-namespaces -o json \
    | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' \
    | while read -r ns name; do
        echo "Deleting svc/$name in namespace $ns"
        kubectl delete svc "$name" -n "$ns"
      done
  echo "Waiting 30s for the AWS load balancer to finish deprovisioning..."
  sleep 30
else
  echo "No LoadBalancer services found — nothing to clean up here."
fi

echo "== Step 2: terraform destroy =="
terraform destroy -auto-approve

echo "== Step 3: manual checks (Terraform/kubectl can't always catch these) =="
echo "Go verify in the AWS Console that these are empty for your account/region:"
echo "  - EC2 > Load Balancers"
echo "  - EC2 > Elastic IPs (unattached EIPs bill even when idle)"
echo "  - EC2 > Volumes (orphaned EBS from deleted nodes)"
echo "  - VPC > NAT Gateways (none should exist — this stack doesn't create any)"
echo "  - Billing > Cost Explorer, filtered by tag Project=${1:-nlp-sentinel-test}"
