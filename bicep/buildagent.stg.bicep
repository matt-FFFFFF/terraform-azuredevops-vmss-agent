param storageAccountName string
param storageAccountSku string
param vmssPrincipalId string

var roleDefinition_storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource ra 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('${vmssPrincipalId}${stg.id}${roleDefinition_storageBlobDataContributor}')
  scope: stg
  properties: {
    principalId: vmssPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions',roleDefinition_storageBlobDataContributor)
  }
}

output storageAccount object = stg
