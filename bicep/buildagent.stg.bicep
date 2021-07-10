/*
 Summary: Provisions a storage account with private link and private DNS zone
*/

// ============================================================================
// Parameters

@description('The storage account name')
param storageAccountName string

@description('The storage account SKU, e.g. Standard_ZRS')
param storageAccountSku string

@description('Full resource id of the virtual network in which to create the private endpoint')
param subnetResourceId string

@description('Azure AD principal id of the VMSS managed identity')
param vmssPrincipalId string

@description('Full resource id of the virtual network in which to create the private endpoint')
param vnetResourceId string

// ============================================================================
// Variables

// Built-in roleDefinition GUID for storage blob data contributor
var roleDefinition_storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// DNS zone name for the blob service
var privateLink_dns_zone = 'privatelink.blob.${environment().suffixes.storage}'

// ============================================================================
// Resources

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
     bypass: 'None'
     virtualNetworkRules: []
     ipRules: []
     defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
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
  name: '${stg.name}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${stg.name}-svccon'
        properties: {
          privateLinkServiceId: stg.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource pdnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: '${stg.name}-dnszonegroup'
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
