# 🧪 DevOps Hands-on Assignment

## 🎯 Objective

Deploy the provided Python application to Azure using modern DevOps practices.

This assignment focuses on:

* Infrastructure as Code (IaC)
* CI/CD pipeline
* Multi-environment deployment
* Secure configuration (Managed Identity)
* Logging & alerting

---

## 📦 Application Overview

This is a simple FastAPI application with the following endpoints:

| Endpoint   | Description                                           |
| ---------- | ----------------------------------------------------- |
| `/`        | GUI                                       |
| `/health`  | Health check                                          |
| `/counter` | Stores and increments a counter in Azure Blob Storage |

---

## 🐍 Running the Application Locally

### 1. Install dependencies

```bash
pip install -r app/requirements.txt
```

---

### 2. Configure Environment Variables

Environment variables are **not auto-loaded**. You must set them manually.

You may:

* Export variables in your shell
* OR use `.env` with tools like `python-dotenv` (optional)

---

### 🔐 Option A: Managed Identity (Recommended for Azure)

```bash
export USE_MANAGED_IDENTITY=true
export BLOB_ACCOUNT_URL=https://<storage-account>.blob.core.windows.net
export BLOB_CONTAINER=appdata
export BLOB_NAME=counter.json
```

---

### 🔑 Option B: Connection String (Local Development)

```bash
export USE_MANAGED_IDENTITY=false
export BLOB_CONNECTION_STRING="<your-connection-string>"
export BLOB_CONTAINER=appdata
export BLOB_NAME=counter.json
```

---

### 3. Run the Application

```bash
cd app
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

### 4. Test Endpoints

* http://localhost:8000/
* http://localhost:8000/health
* http://localhost:8000/counter

Refresh `/counter` to verify persistence.

---

## ⚙️ Assignment Requirements

---

### 1️⃣ Containerization

* Create a Dockerfile for this application
* Build and run the container

#### Expectations:

* Use best practices
* Optimize image size
* Use secure base image

---

### 2️⃣ Infrastructure as Code

Use **Terraform or Bicep**

#### Must provision:

* Resource Group

* Container Registry

* Compute platform (choose one):

  * App Service
  * AKS
  * Container Apps
  * Any equivalent Azure compute service

* Azure Blob Storage

---

### 3️⃣ Multi-Environment Setup (Mandatory)

Support at least:

* `dev`
* `prod`

---

### 🔥 Environment Differences (IMPORTANT)

Your environments **must not be identical**.

Define meaningful differences such as:

| Area         | dev             | prod                   |
| ------------ | --------------- | ---------------------- |
| Scaling      | minimal / fixed | autoscaling enabled    |
| Compute size | small           | medium or optimized    |
| Availability | single instance | multi-instance         |
| Logging      | basic           | enhanced / centralized |
| Alerts       | minimal         | stricter thresholds    |

---

### 4️⃣ CI/CD Pipeline

Use **Azure DevOps or GitHub Actions**

#### Pipeline should:

1. Build Docker image
2. Push image to registry
3. Deploy infrastructure (IaC)
4. Deploy application
5. Validate `/health` endpoint

#### Bonus:

* Separate stages (build / deploy / validate)
* Manual approval before production
* Separate pipelines or workflows per environment

---

### 5️⃣ Storage Integration

* Use Azure Blob Storage
* `/counter` endpoint must persist data

#### Requirements:

* Managed Identity (preferred)
* Connection string allowed for local/dev only

---

### 6️⃣ Security

* Do NOT hardcode secrets
* Use environment variables

#### Bonus:

* Managed Identity end-to-end
* RBAC-based access

---

### 7️⃣ Logging & Monitoring

* Enable application logs
* Centralize logs (e.g., Log Analytics or equivalent)

#### Must demonstrate:

* How to access logs
* Basic troubleshooting steps

---

### 8️⃣ Alerts

* Configure at least one alert

Examples:

* Application failure
* High error rate
* Resource health issue

---

## 🌐 Optional (Bonus)

* Private networking (restrict storage access)
* Key Vault integration
* Managed Identity everywhere
* AKS with Helm
* Autoscaling (HPA / rules)
* Blue/green or rolling deployment strategy

---

## 📤 Submission Instructions

1. Fork this repository into your own GitHub account
2. Complete the assignment in your forked repository
3. Share the repository URL for review

---

## 📤 Deliverables

Your repository should contain:

* Infrastructure code (Terraform/Bicep)
* CI/CD pipeline configuration
* Dockerfile
* Deployment configuration

---

### README must include:

* Architecture diagram
* Steps to deploy
* Explanation of environment differences
* Design decisions
* How to access logs
* How alerts are configured

---

## ⏱️ Time Expectation

* Estimated effort: **4–6 hours**
* Maximum: **2 days**

---

## 🧠 Evaluation Criteria

---

### ✅ Core Requirements

* End-to-end deployment works
* Multi-environment setup is clear
* CI/CD pipeline functional
* No hardcoded secrets
* Logging enabled

---

### ⭐ Strong Signals

* Clear separation between dev and prod
* Good IaC structure
* Pipeline design maturity
* Thoughtful trade-offs

---

### 🚀 Bonus Signals

* AKS / Container Apps implementation
* Managed Identity correctly configured
* Private networking
* Advanced alerting

---

## 🚨 Important Notes

* Focus on DevOps practices over application changes
* Keep costs minimal (use lowest-tier resources)
* Ensure solution is reproducible

---

## 🎯 Final Validation

We should be able to:

* Deploy both dev and prod environments
* Access the application
* Verify `/counter` increments
* View logs
* Validate alerts

---
