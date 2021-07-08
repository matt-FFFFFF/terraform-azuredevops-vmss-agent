
param keyVaultName string
param vmssPrincipalId string

var roleDefinition_keyVaultSecretsUser = '4633458b-17de-408a-b874-0445c86b69e6'

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource ra 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('${vmssPrincipalId}${kv.id}${roleDefinition_keyVaultSecretsUser}')
  scope: kv
  properties: {
    principalId: vmssPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions',roleDefinition_keyVaultSecretsUser)
  }
}

output vault object = kv
