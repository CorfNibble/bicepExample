param principalId string
param keyVaultName string


// Grab the Key vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName  // Existing Key Vault name
}



// Key Vault Access Policy resource so ver can add the service so we can test
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: tenant().tenantId  // Dynamically obtain the tenant ID
      }
    ]
  }
}
