/*
 Summary: Provisions a virtual network with one subnet, then assigns an NSG preventing inbound connections
*/

// ============================================================================
// Parameters

@description('Location for resources')
param location string = resourceGroup().location

@description('Virtual network address prefix, e.g. 10.0.0.0/28')
param vnetAddressPrefix string

// ============================================================================
// Resources

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'buildagent-vnet'
  location: location
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
  location: location
  properties: {
    securityRules: []
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'default'
}

// ============================================================================
// Outputs

output virtualNetwork object = vnet
output subnetResourceId string = subnet.id
output vnetResourceId string = vnet.id
