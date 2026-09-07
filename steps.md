# Steps for the Project

```markdown
# Execution Guide & Step-by-Step Commands

Complete walkthrough of setup, configuration, deployment, and monitoring commands for the **NLP Sentinel MLOps** platform.

---

## 1. Project Initialization & Structure

```bash
# 1. Clone the repository and navigate to root
git clone [https://github.com/anish3565/NLP_Sentinel_Mlops.git](https://github.com/anish3565/NLP_Sentinel_Mlops.git)
cd NLP_Sentinel_Mlops

# 2. Create and activate virtual environment
python -m venv venv

# Windows (PowerShell):
venv\Scripts\activate

# Linux / macOS:
source venv/bin/activate

# 3. Initialize cookiecutter structure
pip install cookiecutter
cookiecutter -c v1 [https://github.com/drivendata/cookiecutter-data-science](https://github.com/drivendata/cookiecutter-data-science)

# 4. Rename models directory to model if needed
# Rename-Item -Path "src\models" -NewName "src\model"

```

---

## 2. MLflow & DagsHub Experiment Tracking

```bash
# 1. Install MLflow and DagsHub integration
pip install dagshub mlflow

# 2. Set DagsHub auth token in environment (PowerShell)
$env:CAPSTONE_TEST="<YOUR_DAGSHUB_TOKEN>"

# Linux / macOS:
export CAPSTONE_TEST="<YOUR_DAGSHUB_TOKEN>"

```

---

## 3. DVC Pipeline & AWS S3 Remote Storage

```bash
# 1. Initialize DVC
dvc init

# 2. Configure AWS credentials
aws configure

# 3. Install DVC S3 dependencies
pip install "dvc[s3]"

# 4. Add S3 bucket as remote storage
dvc remote add -d myremote s3://<YOUR_S3_BUCKET_NAME>

# 5. Reproduce pipeline and track state
dvc repro
dvc status

# 6. Push data and model artifacts to S3
dvc push

```

---

## 4. Containerization with Docker

```bash
# 1. Generate clean dependencies for the Flask service
cd flask_app
pip install pipreqs
pipreqs . --force
cd ..

# 2. Build Docker container image
docker build -t capstone-app:latest .

# 3. Test container locally
docker run -p 5000:5000 -e CAPSTONE_TEST="<YOUR_DAGSHUB_TOKEN>" capstone-app:latest

```

---

## 5. Kubernetes & AWS EKS Deployment

### Step A: CLI Tools Setup (Windows PowerShell)

```powershell
# 1. Download & move kubectl
Invoke-WebRequest -Uri "[https://dl.k8s.io/release/v1.28.2/bin/windows/amd64/kubectl.exe](https://dl.k8s.io/release/v1.28.2/bin/windows/amd64/kubectl.exe)" -OutFile "kubectl.exe"
Move-Item -Path .\kubectl.exe -Destination "C:\Windows\System32"

# 2. Download & move eksctl
Invoke-WebRequest -Uri "[https://github.com/weaveworks/eksctl/releases/download/v0.158.0/eksctl_Windows_amd64.zip](https://github.com/weaveworks/eksctl/releases/download/v0.158.0/eksctl_Windows_amd64.zip)" -OutFile "eksctl.zip"
Expand-Archive -Path .\eksctl.zip -DestinationPath .
Move-Item -Path .\eksctl.exe -Destination "C:\Windows\System32\eksctl.exe"

# 3. Verify CLI installations
aws --version
kubectl version --client
eksctl version

```

### Step B: Provision Cluster & Apply Manifests

```powershell
# 1. Create single-node EKS cluster
eksctl create cluster --name flask-app-cluster --region us-east-1 --nodegroup-name flask-app-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 1 --managed

# 2. Update local kubeconfig
aws eks --region us-east-1 update-kubeconfig --name flask-app-cluster

# 3. Verify node connectivity
kubectl get nodes

# 4. Create Kubernetes ECR pull secret
$ECR_TOKEN = aws ecr get-login-password --region us-east-1
kubectl create secret docker-registry ecr-secret `
  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com `
  --docker-username=AWS `
  --docker-password=$ECR_TOKEN `
  --namespace=default --dry-run=client -o yaml | kubectl apply -f -

# 5. Apply deployment and load balancer manifests
kubectl apply -f deployment.yaml

# 6. Monitor pod rollout
kubectl get pods -w

# 7. Get public LoadBalancer external DNS
kubectl get svc flask-app-service

```

---

## 6. Prometheus Server Setup (Ubuntu EC2, Port 9090)

```bash
# 1. SSH into Prometheus EC2 instance
ssh -i your-key.pem ubuntu@<PROMETHEUS_EC2_PUBLIC_IP>

# 2. Update system and download binary
sudo apt update && sudo apt upgrade -y
wget [https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz](https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz)
tar -xvzf prometheus-2.46.0.linux-amd64.tar.gz
sudo mv prometheus-2.46.0.linux-amd64 /etc/prometheus
sudo mv /etc/prometheus/prometheus /usr/local/bin/

# 3. Configure scrape target in /etc/prometheus/prometheus.yml
sudo nano /etc/prometheus/prometheus.yml

```

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "flask-app"
    metrics_path: /metrics
    static_configs:
      - targets: ["<LOAD_BALANCER_EXTERNAL_DNS>:5000"]

```

```bash
# 4. Launch Prometheus
/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml

```

---

## 7. Grafana Dashboard Setup (Ubuntu EC2, Port 3000)

```bash
# 1. SSH into Grafana EC2 instance
ssh -i your-key.pem ubuntu@<GRAFANA_EC2_PUBLIC_IP>

# 2. Install and start Grafana
sudo apt update && sudo apt upgrade -y
wget [https://dl.grafana.com/oss/release/grafana_10.1.5_amd64.deb](https://dl.grafana.com/oss/release/grafana_10.1.5_amd64.deb)
sudo apt install ./grafana_10.1.5_amd64.deb -y
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# 3. Verify service status
sudo systemctl status grafana-server --no-pager

```

1. Open `http://<GRAFANA_EC2_PUBLIC_IP>:3000` (Default: `admin` / `admin`).
2. Add Prometheus data source pointing to `http://<PROMETHEUS_EC2_PUBLIC_IP>:9090`.
3. Create dashboards to track request counts (`http_requests_total`) and prediction latency.

---

## 8. AWS Teardown & Resource Cleanup

```powershell
# 1. Delete Kubernetes workloads & secrets
kubectl delete deployment flask-app
kubectl delete service flask-app-service
kubectl delete secret capstone-secret

# 2. Delete EKS Cluster & CloudFormation Stacks
eksctl delete cluster --name flask-app-cluster --region us-east-1

# 3. Verify cluster deletion
eksctl get cluster --region us-east-1

# 4. Terminate EC2 instances (Prometheus and Grafana) via AWS Console

```

```

```