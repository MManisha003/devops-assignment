// Production environment parameters

using '../Bicep/main.bicep'

param environment = 'prod'
param resourceGroupName = 'prod-rg'
param location = 'eastus'
param appServicePlanName = 'prodappserviceplan'
param appServicePlanSku = {
  name: 'S1'
  tier: 'Standard'
  capacity: 2
}
param autoScaleCapacity = {
  min: 2
  max: 5
  default: 2
}
param autoScaleRules = [
  {
    metricName: 'CpuPercentage'
    operator: 'GreaterThan'
    threshold: 70
    timeAggregation: 'Average'
    direction: 'Increase'
    changeCount: 1
    cooldown: 'PT5M'
  }
  {
    metricName: 'CpuPercentage'
    operator: 'LessThan'
    threshold: 30
    timeAggregation: 'Average'
    direction: 'Decrease'
    changeCount: 1
    cooldown: 'PT5M'
  }
]
param webAppName = 'prodwebapp'
param containerImageName = 'fastapi-app'
param containerImageTag = 'prod-latest'
param logAnalyticsWorkspaceName = 'prodloganalytics'
param logAnalyticsWorkspaceSku = {
  name: 'PerGB2018'
}
param logAnalyticsWorkspaceRetentionInDays = 90
param applicationInsightsName = 'prodappinsights'
param containerRegistryName = 'prodcontainerregistry'
param containerRegistrySku = {
  name: 'Standard'
}
param webAppKind = 'app,linux,container'
param storageAccountName = 'prodstorageaccount'
param storageAccountSku = {
  name: 'Standard_GRS'
}
param storageBlobContainerName = 'appdata'
param storageBlobServicePolicies = {
  deleteRetentionPolicy: {
    enabled: true
    days: 30
  }
}
param storageBlobName = 'counter.json'
param storageBlobRoleDefinitionId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
param containerPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

