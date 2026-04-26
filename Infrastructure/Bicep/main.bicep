// This Bicep file is used to deploy the complete infratsructure for the project.
// It includes the following resources:
// - Azure Container Registry
// - Storage Account
// - Container Apps Environment
// - Container App
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
// Container Apps Parameters
param containerAppsEnvironmentName string
param containerAppName string
param containerAppConfiguration object
param containerCpu int
param containerMemory string
param containerMinReplicas int
param containerMaxReplicas int
param environment string
// Container Parameters
param containerImageName string
param containerImageTag string
param storageBlobName string
// Monitoring Parameters
param metricAlertsProperties object = {}
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
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerAppName: containerAppName
    containerAppConfiguration: containerAppConfiguration
    containerCpu: containerCpu
    containerMemory: containerMemory
    containerMinReplicas: containerMinReplicas
    containerMaxReplicas: containerMaxReplicas
    environment: environment
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
    logAnalyticsWorkspaceRetentionInDays: logAnalyticsWorkspaceRetentionInDays
    applicationInsightsName: applicationInsightsName
    metricAlertsProperties: metricAlertsProperties
  }
}

