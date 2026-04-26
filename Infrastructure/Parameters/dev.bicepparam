// Development environment parameters

using '../Bicep/main.bicep'

param environment = 'dev'
param resourceGroupName = 'dev-rg'
param location = 'eastus'
param containerAppsEnvironmentName = 'devdevopsassignmentcae'
param containerAppName = 'devdevopsassignmentapp'
param containerAppConfiguration = {
  ingress: {
    external: true
    targetPort: 8000
    transport: 'http'
  }
}
param containerCpu = '0.25'
param containerMemory = '0.5Gi'
param containerMinReplicas = 1
param containerMaxReplicas = 1
param containerImageName = 'fastapi-app'
param containerImageTag = 'dev-latest'
param logAnalyticsWorkspaceName = 'devdevopsassignmentlaw'
param logAnalyticsWorkspaceSku = {
  name: 'PerGB2018'
}
param logAnalyticsWorkspaceRetentionInDays = 30
param applicationInsightsName = 'devdevopsassignmentai'
param containerRegistryName = 'devdevopsassignmentacr'
param containerRegistrySku = {
  name: 'Basic'
}
param storageAccountName = 'devdevopsassignmentsa'
param storageAccountSku = {
  name: 'Standard_LRS'
}
param storageBlobContainerName = 'appdata'
param storageBlobName = 'counter.json'
param storageBlobServicePolicies = {
  deleteRetentionPolicy: {
    enabled: true
    days: 7
  }
}
param storageBlobRoleDefinitionId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
param containerPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

