/*
 Summary: Provisions an Ubuntu VM Scale Set for usew with Azure DevOps
*/

// ============================================================================
// Parameters

@description('Admin username for VMs')
param adminUserName string

@description('Cloud Init file encoded as base64')
param customDataBase64 string

@description('Location for resources')
param location string = resourceGroup().location

@description('VM SKU to use for VM scale set')
param vmSku string

@description('Subnet resourceId to link the VMSS to')
param subnetResourceId string

@description('Administrative SSH key for the VM')
param adminSshPubKey string

// ============================================================================
// Resources

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-03-01' = {
  name: 'buildagent'
  location: location
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
                       id: subnetResourceId
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

// ============================================================================
// Outputs

output principalId string = vmss.identity.principalId
