# NLP Sentinel MLOps: Cloud-Native Sentiment Analysis Platform

Production-grade, end-to-end MLOps platform for automated NLP sentiment inference. This project covers data version control (**DVC + AWS S3**), experiment tracking and remote model registry (**MLflow + DagsHub**), containerization (**Docker + AWS ECR**), continuous integration and automated deployment (**GitHub Actions**), managed Kubernetes orchestration (**AWS EKS**), and real-time observability (**Prometheus + Grafana**).

[![CI/CD Pipeline](https://github.com/anish3565/NLP_Sentinel_Mlops/actions/workflows/ci.yaml/badge.svg)](https://github.com/anish3565/NLP_Sentinel_Mlops/actions)
[![DVC](https://img.shields.io/badge/Data_Version_Control-DVC_with_S3-945DD6?logo=dvc&logoColor=white)](https://dvc.org/)
[![MLflow & DagsHub](https://img.shields.io/badge/Experiment_Tracking-MLflow_%26_DagsHub-0194E2?logo=mlflow&logoColor=white)](https://dagshub.com/)
[![Docker](https://img.shields.io/badge/Container-Docker_%26_AWS_ECR-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS EKS](https://img.shields.io/badge/Orchestration-AWS_EKS_Cluster-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform&logoColor=white)](terraform/README.md)
[![Observability](https://img.shields.io/badge/Monitoring-Prometheus_%26_Grafana-F46800?logo=prometheus&logoColor=white)](https://prometheus.io/)

### 🎥 [Watch the full walkthrough](https://youtu.be/B0-Jx-8aWn8) — CI/CD, Terraform, live deployment, and monitoring, end to end

[![Watch the demo](https://img.youtube.com/vi/B0-Jx-8aWn8/maxresdefault.jpg)](https://youtu.be/B0-Jx-8aWn8)

---

## Execution & Deployment Guide

For detailed, step-by-step commands covering local setup, DVC pipelines, AWS EKS deployment, and monitoring configuration, see the [Full Step-by-Step Guide](steps.md).

---

## Infrastructure as Code (Terraform)

The AWS infrastructure behind this project (VPC, EKS cluster, ECR repository,
S3 bucket, and the Prometheus/Grafana EC2 instances) can be provisioned
declaratively with Terraform instead of the manual `eksctl`/console steps
in `steps.md`. This gives a reproducible, version-controlled path to stand
up and tear down the entire stack.

See [`terraform/README.md`](terraform/README.md) for the full setup guide,
including cost breakdown, the safety measures used to avoid unattended
billing (no NAT Gateway, IP-restricted security groups, an AWS Budget
created as part of the stack), and the teardown procedure.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

---

## System Architecture

```text
               +-------------------------------------------------------------+
               |                  1. DATA & EXPERIMENTATION                  |
               |  Raw Data -> DVC Pipeline (AWS S3 Remote) -> DagsHub MLflow |
               +------------------------------+------------------------------+
                                              |
                                              v
               +-------------------------------------------------------------+
               |                     2. CI/CD AUTOMATION                     |
               |   GitHub Push -> PyTest -> Docker Build -> AWS ECR Registry |
               +------------------------------+------------------------------+
                                              |
                                              v
               +-------------------------------------------------------------+
               |             3. KUBERNETES DEPLOYMENT (Terraform-provisioned)|
               |     AWS EKS Cluster (t3.small Node) -> AWS Load Balancer    |
               |           Flask Service (/predict & /metrics)               |
               +------------------------------+------------------------------+
                                              |
                                              v
               +-------------------------------------------------------------+
               |                 4. MONITORING & OBSERVABILITY               |
               |  Prometheus Server (EC2 :9090) <-> Grafana Server (EC2 :3000)|
               +-------------------------------------------------------------+

```

---

## Tech Stack

* **Data Engineering & Tracking:** Python, Cookiecutter Data Science, DVC (Data Version Control), AWS S3, MLflow, DagsHub
* **Model Inference & Serving:** Flask, NLTK / Scikit-Learn, Prometheus Client Exporter
* **Containerization:** Docker Desktop, Amazon Elastic Container Registry (ECR)
* **Orchestration & Infrastructure:** Amazon Elastic Kubernetes Service (EKS), `kubectl`, `eksctl`, AWS CloudFormation, Terraform
* **CI/CD:** GitHub Actions
* **Monitoring & Alerting:** Prometheus, Grafana on AWS EC2

---

## Project Structure

```text
.
├── .github/
│   └── workflows/
│       └── ci.yaml                 # CI/CD pipeline automation manifest
├── data/                           # Data directory tracked by DVC
├── flask_app/
│   ├── templates/                  # Web interface templates
│   ├── app.py                      # Flask API serving /predict and /metrics
│   └── requirements.txt            # Application-specific dependencies
├── deployment.yaml                 # Kubernetes Deployment and Service manifests
├── terraform/
│   ├── main.tf                     # Provider config and shared locals/tags
│   ├── variables.tf                # Input variables (region, sizing, etc.)
│   ├── vpc.tf                      # VPC and public subnets
│   ├── eks.tf                      # EKS cluster and managed node group
│   ├── ecr.tf                      # ECR repository
│   ├── s3.tf                       # S3 bucket for DVC remote storage
│   ├── ec2-monitoring.tf           # Prometheus/Grafana EC2 instances
│   ├── budget.tf                   # AWS Budget cost-alert resource
│   ├── outputs.tf                  # kubectl config command, URLs, etc.
│   ├── destroy.sh                  # Safe teardown (LoadBalancer-aware)
│   └── README.md                   # Terraform-specific setup guide
├── scripts/                        # Automated CI/CD execution and test scripts
├── src/
│   ├── __init__.py
│   ├── logger.py                   # Centralized logging module
│   ├── data_ingestion.py           # Dataset ingestion
│   ├── data_preprocessing.py       # Text cleaning and tokenization
│   ├── feature_engineering.py      # TF-IDF / Feature transformations
│   ├── model_building.py           # Model training
│   ├── model_evaluation.py         # Performance evaluation & metrics export
│   └── register_model.py           # MLflow model registration to DagsHub
├── tests/                          # PyTest unit and integration tests
├── Dockerfile                      # Production Dockerfile
├── dvc.yaml                        # DVC pipeline stages definition
├── params.yaml                     # Pipeline parameters and hyperparameters
├── requirements.txt                # Root dependencies
└── README.md

```

---

## Quick Workflow Reference

* For full command-by-command instructions across local setup, DVC, AWS EKS, Prometheus, Grafana, and teardown, refer to [`steps.md`](steps.md).

### CI/CD Environment Variables Required

Configure these secrets in **GitHub Repository > Settings > Secrets and variables > Actions**:

| Secret Name | Description |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | IAM User Access Key |
| `AWS_SECRET_ACCESS_KEY` | IAM User Secret Access Key |
| `AWS_REGION` | AWS Region (e.g. `ap-south-1`) |
| `AWS_ACCOUNT_ID` | 12-digit AWS Account ID |
| `ECR_REPOSITORY` | AWS ECR Repository Name |
| `CAPSTONE_TEST` | DagsHub MLflow Auth Token |