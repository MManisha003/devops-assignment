// Create resources in the resource group

targetScope = 'resourceGroup'

// Common Parameters

param environment string

// User Assigned Identity Parameters

param userAssignedIdentityName string


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

// Container Apps Parameters
param containerAppsEnvironmentName string
param containerAppName string
param containerAppConfiguration object
param containerCpu string
param containerMemory string
param containerMinReplicas int
param containerMaxReplicas int

// Container Parameters
param containerImageName string
param containerImageTag string

// Monitoring Parameters
param metricAlertsProperties object = {}

// Log Analytics Workspace Parameters
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceSku object
param logAnalyticsWorkspaceRetentionInDays int

// Application Insights Parameters
param applicationInsightsName string

// create a user assigned identity

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedIdentityName
  location: resourceGroup().location
}


// Create an Azure Container Registry

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryName
  location: resourceGroup().location
  sku: containerRegistrySku
  properties: {
    adminUserEnabled: true
  }
  dependsOn: [
    userAssignedIdentity
   ]
}

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acr.id, userAssignedIdentity.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', containerPullRoleDefinitionId) // AcrPull
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    description: 'Allow Container App to pull from ACR'
  }
}

// Create a Container Apps Environment

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: containerAppsEnvironmentName
  location: resourceGroup().location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Create a Container App

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: union(containerAppConfiguration, { registries: [
      {
        server: acr.properties.loginServer
        identity: userAssignedIdentity.id
      }
    ]})
    template: {
      containers: [
        {
          name: containerImageName
          image: '${acr.properties.loginServer}/${containerImageName}:${containerImageTag}'
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'USE_MANAGED_IDENTITY'
              value: 'true'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: userAssignedIdentity.properties.clientId
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
          ]
        }
      ]
      scale: {
        minReplicas: containerMinReplicas
        maxReplicas: containerMaxReplicas
      }
    }
  }
  dependsOn: [
    acrRoleAssignment
    storageBlobRoleAssignment
  ]
}

// Adding Metric Alert for cpu time to monitor the Web App's performance

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (environment == 'prod') {
  name: '${containerAppName}-cpu-alert'
  location: 'global'
  properties: union({
    scopes: [
      containerApp.id
    ]
  }, metricAlertsProperties)
}

// Create a Storage Account

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: storageAccountSku
  kind: 'StorageV2'
  dependsOn: [
    userAssignedIdentity
  ]
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

// Assigning Storage Blob Data Contributor role to the user assigned identity for the blob container

resource storageBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageBlobContainer.id, userAssignedIdentity.id, 'StorageBlobDataContributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobRoleDefinitionId) // Storage Blob Data Contributor
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    description: 'Allow Container App to access Blob Storage'
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
output containerAppName string = containerApp.name
output containerAppUrl string = 'https://${containerAppName}.${containerAppsEnvironment.properties.defaultDomain}'
output deployedImageUri string = '${acr.properties.loginServer}/${containerImageName}:${containerImageTag}'
output acrLoginServer string = acr.properties.loginServer


