// Production environment parameters

using '../Bicep/main.bicep'

param environment = 'prod'
param resourceGroupName = 'prod-rg'
param location = 'eastus'
param containerAppsEnvironmentName = 'proddevopsassignmentcae'
param containerAppName = 'proddevopsassignmentapp'
param containerAppConfiguration = {
  ingress: {
    external: true
    targetPort: 8000
    transport: 'http'
  }
}
param containerCpu = '1Gi'
param containerMemory = '1.0Gi'
param containerMinReplicas = 2
param containerMaxReplicas = 5
param metricAlertsProperties = {
  severity: 2
  enabled: true
  evaluationFrequency: 'PT1M'
  windowSize: 'PT5M'
  criteria: {
    allOf: [
      {
        alertSensitivity: 'Medium'
        fallingPeriods: {
          numberOfEvaluationPeriods: 4
          minFailingPeriodsToAlert: 4
        }
        name: 'Metric1'
        metricNamespace: 'Microsoft.App/containerApps'
        metricName: 'CPUUsage'
        operator: 'GreaterThan'
        threshold: 80
        timeAggregation: 'Maximum'
        skipMetricValidation: false
        criteriaType: 'StaticThresholdCriterion'
      }
    ]
  }
}
param containerImageName = 'python-api'
param containerImageTag = 'latest'
param logAnalyticsWorkspaceName = 'proddevopsassignmentlaw'
param logAnalyticsWorkspaceSku = {
  name: 'PerGB2018'
}
param logAnalyticsWorkspaceRetentionInDays = 90
param applicationInsightsName = 'proddevopsassignmentai'
param containerRegistryName = 'proddevopsassignmentacr'
param containerRegistrySku = {
  name: 'Standard'
}
param storageAccountName = 'proddevopsassignmentsa'
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

