```markdown
# NLP Sentinel MLOps: Cloud-Native Sentiment Analysis Platform

[![CI/CD Pipeline](https://github.com/anish3565/NLP_Sentinel_Mlops/actions/workflows/ci.yaml/badge.svg)](https://github.com/anish3565/NLP_Sentinel_Mlops/actions)
[![DVC](https://img.shields.io/badge/Data_Version_Control-DVC_with_S3-945DD6?logo=dvc&logoColor=white)](https://dvc.org/)
[![MLflow & DagsHub](https://img.shields.io/badge/Experiment_Tracking-MLflow_%26_DagsHub-0194E2?logo=mlflow&logoColor=white)](https://dagshub.com/)
[![Docker](https://img.shields.io/badge/Container-Docker_%26_AWS_ECR-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS EKS](https://img.shields.io/badge/Orchestration-AWS_EKS_Cluster-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Observability](https://img.shields.io/badge/Monitoring-Prometheus_%26_Grafana-F46800?logo=prometheus&logoColor=white)](https://prometheus.io/)

Production-grade, end-to-end MLOps platform for automated NLP sentiment inference. This project covers data version control (**DVC + AWS S3**)[cite: 1], experiment tracking and remote model registry (**MLflow + DagsHub**)[cite: 1], containerization (**Docker + AWS ECR**)[cite: 1], continuous integration and automated deployment (**GitHub Actions**)[cite: 1], managed Kubernetes orchestration (**AWS EKS**)[cite: 1], and real-time observability (**Prometheus + Grafana**)[cite: 1].

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
               |                   3. KUBERNETES DEPLOYMENT                  |
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


* **Orchestration & Infrastructure:** Amazon Elastic Kubernetes Service (EKS), `kubectl`, `eksctl`, AWS CloudFormation


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
├── k8s/
│   └── deployment.yaml             # Kubernetes Deployment and Service manifests
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

* For full command-by-command instructions across local setup, DVC, AWS EKS, Prometheus, Grafana, and teardown, refer to `COMMANDS.md`.

### CI/CD Environment Variables Required

Configure these secrets in **GitHub Repository > Settings > Secrets and variables > Actions**:

| Secret Name | Description |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | IAM User Access Key

 |
| `AWS_SECRET_ACCESS_KEY` | IAM User Secret Access Key

 |
| `AWS_REGION` | AWS Region (e.g. `us-east-1`)

 |
| `AWS_ACCOUNT_ID` | 12-digit AWS Account ID

 |
| `ECR_REPOSITORY` | AWS ECR Repository Name

 |
| `CAPSTONE_TEST` | DagsHub MLflow Auth Token

 |

---

## License

Distributed under the MIT License. See `LICENSE` for details.

```

```