/*
 Summary: Provisions a virtual network with one subnet, then assigns an NSG preventing inbound connections
*/

// ============================================================================
// Parameters

@description('Virtual network address prefix, e.g. 10.0.0.0/28')
param vnetAddressPrefix string

// ============================================================================
// Resources

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'buildagent-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: vnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'buildagent-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

// ============================================================================
// Outputs

output virtualNetwork object = vnet
// We need the below as we can't currently output a resource,
// using the object output and assigning the resource does not give us the full resourceId
output subnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets',vnet.name,vnet.properties.subnets[0].name)
output vnetResourceId string = resourceId('Microsoft.Network/virtualNetworks',vnet.name)
