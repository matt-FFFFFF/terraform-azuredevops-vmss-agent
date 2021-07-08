@description('Admin username for VMs')
param adminUserName string

@description('Cloud Init file encoded as base64')
param customDataBase64 string

@description('VM SKU to use for VM scale set')
param vmSku string

@description('Virtual network address prefix, e.g. 10.0.0.0/24')
param vnetAddressPrefix string

@description('Administrative SSH key for the VM')
param adminSshPubKey string

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

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-03-01' = {
  name: 'buildagent'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: vmSku
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      automaticOSUpgradePolicy: {
        enableAutomaticOSUpgrade: false
      }
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadOnly'
          createOption: 'FromImage'
        }
        imageReference: {
          offer: '0001-com-ubuntu-server-focal'
          publisher: 'Canonical'
          sku: '20_04-lts'
          version: 'latest'
        }
      }
      osProfile: {
        computerNamePrefix: 'buildagent'
        adminUsername: adminUserName
        linuxConfiguration: {
          provisionVMAgent: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUserName}/.ssh/authorized_keys'
                keyData: adminSshPubKey
              }
            ]
          }
        }
        customData: customDataBase64
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'buildagent-nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'buildagent-ipconfig'
                  properties: {
                     subnet: {
                       id: vnet.properties.subnets[0].id
                     }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output principalId string = vmss.identity.principalId
