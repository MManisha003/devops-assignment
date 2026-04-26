// This Bicep file is used to deploy the complete infratsructure for the project.
// It includes the following resources:
// - Azure Container Registry
// - Storage Account
// - App Service Plan
// - Web App
// - Application Insights

targetScope = 'subscription'

// Parameters

param location string
param resourceGroupName string
// ACR Parameters
param containerRegistryName string
param containerRegistrySku object
// Storage Parameters
param storageAccountName string
param storageAccountSku object
param storageBlobServicePolicies object
param storageBlobContainerName string
param storageBlobRoleDefinitionId string
// App Service Parameters
param appServicePlanName string
param appServicePlanSku object
param webAppKind string
param environment string
param autoScaleRules array = []
param autoScaleCapacity object = {}
// Web App Parameters
param webAppName string
param containerImageName string
param containerImageTag string
param storageBlobName string
// Logging Parameters
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceSku object
param logAnalyticsWorkspaceRetentionInDays int
// Application Insights Parameters
param applicationInsightsName string
// RBAC Parameters
param containerPullRoleDefinitionId string

// Create a resource group

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy Infrastructure Module
module infra 'infra.bicep' = {
  name: 'deployInfra'
  scope: rg
  params: {
    containerRegistryName: containerRegistryName
    containerRegistrySku: containerRegistrySku
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    storageBlobServicePolicies: storageBlobServicePolicies
    storageBlobContainerName: storageBlobContainerName
    storageBlobName: storageBlobName
    storageBlobRoleDefinitionId: storageBlobRoleDefinitionId
    containerPullRoleDefinitionId: containerPullRoleDefinitionId
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    environment: environment
    autoScaleRules: autoScaleRules
    autoScaleCapacity: autoScaleCapacity
    webAppName: webAppName
    webAppKind: webAppKind
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
    logAnalyticsWorkspaceRetentionInDays: logAnalyticsWorkspaceRetentionInDays
    applicationInsightsName: applicationInsightsName
  }
}

