// Create resources in the resource group

targetScope = 'resourceGroup'

// Common Parameters

param environment string
// ACR Parameters
param containerRegistryName string
param containerRegistrySku object
param containerPullRoleDefinitionId string

// Storage Account Parameters
param storageAccountName string
param storageAccountSku object
param storageBlobServicePolicies object
param storageBlobContainerName string
param storageBlobName string
param storageBlobRoleDefinitionId string
param appServicePlanName string
param autoScaleCapacity object = {}
param autoScaleRules array = []
param appServicePlanSku object

// Web App Parameters
param webAppName string
param webAppKind string
param containerImageName string
param containerImageTag string
param metricAlertsProperties object = {}

// Log Analytics Workspace Parameters
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceSku object
param logAnalyticsWorkspaceRetentionInDays int

// Application Insights Parameters
param applicationInsightsName string


// Create an Azure Container Registry

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryName
  location: resourceGroup().location
  sku: containerRegistrySku
  properties: {
    adminUserEnabled: true
  }
}

// Create an App Service Plan

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: resourceGroup().location
  sku: appServicePlanSku
}
// Adding MetricTrigger for Auto Scaling the App Service Plan based on CPU usage
var autoScaleRuleObjects = [
  for i in autoScaleRules: {
    scaleAction: i.scaleAction
    metricTrigger: union({metricResourceUri: appServicePlan.id}, i.metricTrigger)
  }
]

resource aspAutoScaleSettings 'Microsoft.Insights/autoscalesettings@2015-04-01' = if (environment == 'prod') {
  name: '${appServicePlanName}-autoscale'
  location: resourceGroup().location
  properties: {
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'Auto Scale Rules'
        capacity: autoScaleCapacity
        rules: autoScaleRuleObjects
      }
    ]
  }
}

// Create a Web App

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: resourceGroup().location
  kind: webAppKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azuredocs/aci-helloworld:latest'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'BLOB_ACCOUNT_URL'
          value: 'https://${storageAccountName}.blob.${az.environment().suffixes.storage}'
        }
        {
          name: 'BLOB_CONTAINER'
          value: storageBlobContainerName
        }
        {
          name: 'BLOB_NAME'
          value: storageBlobName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acr.properties.loginServer}'
        }
      ]
    }
  }
}

// Adding Metric Alert for cpu time to monitor the Web App's performance

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (environment == 'prod') {
  name: '${webAppName}-cpu-alert'
  location: 'global'
  properties: union({
    scopes: [
      webApp.id
    ]
  }, metricAlertsProperties)
}

// Create a Storage Account

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: storageAccountSku
  kind: 'StorageV2'
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: storageBlobServicePolicies
}

resource storageBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: storageAccountBlob
  name: storageBlobContainerName
  properties: {
    publicAccess: 'None'
  }
}

// RBAC for Web App to access Storage Account
resource webAppStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(webApp.id, storageAccount.id, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobRoleDefinitionId) // Storage Blob Data Contributor
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// RBAC for Web App to pull from ACR
resource webAppAcrRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acr.id, webApp.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', containerPullRoleDefinitionId) // AcrPull
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
    description: 'Allow Web App to pull from ACR'
  }
}

// Create a Log Analytics Workspace

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  properties: {
    retentionInDays: logAnalyticsWorkspaceRetentionInDays
    sku: logAnalyticsWorkspaceSku
  }
}

// Create Application Insights

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Outputs
output webAppName string = webApp.name
output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
output deployedImageUri string = '${acr.properties.loginServer}/${containerImageName}:${containerImageTag}'
output acrLoginServer string = acr.properties.loginServer


