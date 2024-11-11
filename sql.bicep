param sqlServerName string
param sqlAdminUsername string
@secure()
param sqlAdminPasswordSecret string
param location string
param vnetName string
param subnetName string
param vnetResourceGroup string = resourceGroup().name
param databaseName string


// Creaate a  SQL sever
resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPasswordSecret
    publicNetworkAccess: 'Disabled' // Disables public access to the SQL Server
  }
}

// SQL Database resource
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
}

// Add and endpoint
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${sqlServerName}-pe'
  location: location
  properties: {
    subnet: {
      id: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: '${sqlServerName}-sql'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}


// pass though the server name to the pipeline
output sqlServerName string = sqlServer.name

