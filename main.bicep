@minLength(3)
param location string = resourceGroup().location
param keyVaultName string
param keyVaultResourceGroup string
param env string
param sqlAdminPasswordSecretName string
param sqlAdminUsername string
param appServiceName string


// Retrive the Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroup)
}

// create dynamic variables
var sqlServerName = '${env}-SQL-${uniqueString(resourceGroup().id)}'
var appVnetName = '${env}-AppVnet-${uniqueString(resourceGroup().id)}'
var myAppServicePlan = '${env}-ServicePlan-${uniqueString(resourceGroup().id)}'
var databaseName = '${env}-db'



/// create Vnet/subnets and apply delegation for the serverFarms
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: appVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AppServiceSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'SQLDatabaseSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}



// Module to deploy the SQL Server, passing in the secret as a parameter
module sql './sql.bicep' = {
  name: 'deploySQL-${uniqueString(resourceGroup().id)}'
  params: {
    vnetName: appVnetName
    subnetName: 'SQLDatabaseSubnet'
    databaseName: databaseName
    sqlServerName: sqlServerName
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPasswordSecret: keyVault.getSecret(sqlAdminPasswordSecretName) // Retrieves the secret
    location: location
  }
}

// Module to create the app Service
module appServiceModule 'appService.bicep' = {
  name: 'AppServiceDeployment'
  params: {
    location: location
    appServicePlanName: myAppServicePlan
    appServiceName: appServiceName
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', appVnetName, 'AppServiceSubnet')
  }
}


// Once the service is up this module creates the keyvault policy for the app 
module keyVaultAccessPolicyModule 'keyVaultAccessPolicy.bicep' = {
  name: 'KeyVaultAccessPolicyDeployment'
  scope: resourceGroup(keyVaultResourceGroup)
  params: {
    principalId: appServiceModule.outputs.principalId
    keyVaultName: keyVault.name

  }
}
