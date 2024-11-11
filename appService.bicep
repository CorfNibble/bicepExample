param location string = resourceGroup().location
param appServicePlanName string
param appServiceName string
param subnetId string


// Start the plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: appServiceName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    virtualNetworkSubnetId: subnetId
    siteConfig: {
      alwaysOn: true
      vnetRouteAllEnabled: true // Moved inside siteConfig to enable VNet routing
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Auto-scaling configuration for CPU usage
resource autoScale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${appServicePlanName}-autoscale'
  location: location
  properties: {
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'CPU-based autoscale'
        capacity: {
          minimum: '1'
          maximum: '10'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 75
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 25
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}



// Turn on virtualNetworkConnections so we can talk to the SQL endpoint
resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2021-02-01' = {
  parent: appService
  name: 'vnet'
  properties: {
    vnetResourceId: subnetId // Ensure this is the full resource ID of the AppServiceSubnet
    isSwift: true // Enable streamlined (swift) VNet integration
  }
}


resource vnetConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  parent: appService
  name: 'AppServiceSubnet'
  properties: {
    vnetResourceId: subnetId // Use the VNet subnet ID for integration
    isSwift: true  // Enables fast VNet integration (if desired)
  }
}

// Pass the principalId to the pipe line
output principalId string = appService.identity.principalId
