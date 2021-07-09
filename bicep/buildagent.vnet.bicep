@description('Virtual network address prefix, e.g. 10.0.0.0/28')
param vnetAddressPrefix string

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

output virtualNetwork object = vnet
output subnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets',vnet.name,vnet.properties.subnets[0].name)
output vnetResourceId string = resourceId('Microsoft.Network/virtualNetworks',vnet.name)
