## 📌 Introduction

This project implements an end-to-end DevOps solution for deploying a containerized FastAPI application on Azure.

It uses Infrastructure as Code (Bicep), YAML-based CI/CD pipelines in Azure DevOps, and Managed Identity to securely connect services without relying on secrets.

The application runs on Azure Container Apps, persists data in Azure Blob Storage, and uses centralized logging for observability. The solution supports multiple environments (dev and prod) with environment-specific configurations.

---

## 🧭 Architecture

### 🔹 Azure Resources

* Azure Container Apps
* Azure Container Registry (ACR)
* Azure Blob Storage
* User Assigned Managed Identity
* Log Analytics Workspace
* Application Insights (configured)

---

### 🔹 Architecture Diagram

```
                ┌──────────────────────────┐
                │        GitHub            │
                └──────────┬───────────────┘
                           │
                           ▼
                ┌──────────────────────────┐
                │   Azure DevOps Pipeline  │
                └──────────┬───────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                                     ▼
┌───────────────────┐             ┌────────────────────┐
│ Azure Container   │             │  Bicep Deployment  │
│ Registry (ACR)    │             │  (Infrastructure)  │
└────────┬──────────┘             └────────┬───────────┘
         │                                 │
         └──────────────┬──────────────────┘
                        ▼
              ┌──────────────────────────┐
              │   Container App         │
              │ (FastAPI Application)   │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌──────────────────────────┐
              │   Azure Blob Storage     │
              │   (counter persistence)  │
              └──────────────────────────┘
```

---

### 🔹 How it Works

* Pipeline builds and pushes Docker image to ACR
* Bicep deploys infrastructure and Container App
* Container App pulls image using Managed Identity
* Application accesses Blob Storage using Managed Identity
* Logs are collected via Log Analytics

---

## 🚀 Deployment

Deployment is handled via YAML pipelines in Azure DevOps.

### 🔹 Steps

1. **Build Image**

   * Docker image built using `linux/amd64` (buildx)
   * Pushed to ACR with `BuildId` tag

2. **Deploy Infrastructure**

   * Bicep templates deployed (`main.bicep` → `infra.bicep`)
   * All resources (RG, ACR, Storage, Container App) are created automatically

3. **Access Application**

https://devdevopsassignmentapp.delightfulpebble-df328eea.eastus.azurecontainerapps.io

* `/health`
* `/counter`

---

## 📸 Evidence

### CI/CD Pipeline

![Infra Pipeline Run](https://github.com/user-attachments/assets/38b1c7ec-9762-4230-b3b9-4e4b8648d786)

![Image Upload Pipeline Run](https://github.com/user-attachments/assets/41173598-8565-4bd0-a242-65658817f63d)

---

### Application Deployment

![Container App](https://github.com/user-attachments/assets/67ad7676-e6e5-4906-81e3-0dc1f55ea1a7)

### 🔹 Notes

* Managed Identity is used for secure access
* No secrets are required
* RBAC propagation may take a short time before `/counter` works

---

## 🌍 Environment Separation

The solution supports **dev** and **prod** environments using parameter and variable files.

### 🔹 Key Differences

| Area       | Dev         | Prod                    |
| ---------- | ----------- | ----------------------- |
| Scaling    | Fixed (1/1) | Scalable / configurable |
| Alerts     | Disabled    | Enabled (CPU alert)     |
| Resources  | Minimal     | Production-ready        |
| Monitoring | Basic       | Enhanced                |

### 🔹 Implementation

* `dev.bicepparam` / `prod.bicepparam`
* `dev.yml` / `prod.yml`
* Conditional logic in Bicep:

```
if (environment == 'prod')
```

---

## 📊 Logging & Monitoring

Logs are collected via **Log Analytics** from Container Apps.

### 🔹 Query Logs

```kusto
ContainerAppConsoleLogs_CL
| sort by TimeGenerated desc
| limit 50
```

### 🔹 Design Choice

Application Insights is provisioned but not used directly because:

* Python requires explicit SDK integration
* Container-level logging is sufficient
* Keeps the solution simple

---

## 🚨 Alerts

A CPU-based alert is configured for the **production environment**.

* Scope: Container App
* Trigger: CPU threshold
* Purpose: Detect performance issues early

Dev environment excludes alerts to reduce noise and cost.

---

## 🧠 Design Decisions

### 🔹 Container Apps

Serverless container platform chosen for simplicity and scalability without infrastructure management.

---

### 🔹 Bicep (Modular IaC)

* `main.bicep` (subscription scope)
* `infra.bicep` (resource module)

Provides clean separation and reusability.

---

### 🔹 Managed Identity

Used for:

* ACR image pull
* Blob Storage access

User-assigned identity chosen for control and reuse.
`AZURE_CLIENT_ID` explicitly configured for reliability.

---

### 🔹 YAML Pipelines

Pipelines are:

* Version-controlled
* Template-based
* Split into image and infrastructure stages

Improves clarity and maintainability.

---

### 🔹 Image Tagging

```
$(Build.BuildId)
```

Ensures traceability and avoids mutable tags.

---

### 🔹 Platform Compatibility

Apple Silicon (ARM) → Azure requires AMD64

```
docker buildx --platform linux/amd64
```

---

### 🔹 Trade-offs

Not implemented (by design):

* Private networking
* Key Vault
* Blue/Green deployments

These can be added but were excluded to keep the solution focused and reproducible.

---

### 🔹 Pipeline Improvement (Future)

Currently, image and infrastructure pipelines are triggered separately.

This can be improved by:

* Passing image tag dynamically between pipelines
* Enabling fully automated end-to-end deployment

---

## ✅ Summary

* Fully automated infrastructure using Bicep
* Secure, secret-free access via Managed Identity
* Working application with persistent storage
* Multi-environment setup
* Logging and alerting in place

The solution is designed to be simple, secure, and aligned with real-world DevOps practices.















