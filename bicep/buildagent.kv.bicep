
param keyVaultName string
param subnetResourceId string
param vmssPrincipalId string
param vnetResourceId string

var privateLink_dns_zone = 'privatelink.vaultcore.azure.net'
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
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: []
    }
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

resource pdns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateLink_dns_zone
  location: 'global'
}

resource pdnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${pdns.name}-link'
  location: 'global'
  parent: pdns
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetResourceId
    }
  }
}

resource pe 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${kv.name}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${kv.name}-svccon'
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource pdnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: '${kv.name}-dnszonegroup'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: pdns.id
        }
      }
    ]
  }
}

output vault object = kv
