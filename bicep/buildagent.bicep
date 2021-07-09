// Subscription deployemnt of RG, then contained resources as modules
targetScope = 'subscription'


// ============================================================================
// Parameters

@description('Admin username for VMs')
param adminUserName string = 'buildagent'

@description('Administrative SSH key for the VM')
param adminSshPubKey string

@description('Cloud Init file encoded as base64')
param customDataBase64 string

@description('Name of Key Vault')
param keyVaultName string

@description('Location to deploy resources, defaults to deployment location')
param location string = deployment().location

@description('Resource group name')
param resourceGroupName string

@description('Storage account name')
param storageAccountName string

@description('Storage account SKU, defaults to Standard_ZRS')
param storageAccountSku string = 'Standard_ZRS'

@description('VM SKU to use for VM scale set')
param vmSku string = 'Standard_B2ms'

@description('Virtual network address prefix, defaults to 10.0.0.0/28')
param vnetAddressPrefix string = '10.0.0.0/28'

// ============================================================================
// Resources

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module vnet 'buildagent.vnet.bicep' = {
  name: 'vnetDeploy'
  scope: rg
  params: {
    vnetAddressPrefix: vnetAddressPrefix
  }
}
module vmss './buildagent.vmss.bicep' = {
  name: 'vmssDeploy'
  scope: rg
  params: {
    adminSshPubKey: adminSshPubKey
    adminUserName: adminUserName
    customDataBase64: customDataBase64
    vmSku: vmSku
    subnetId: vnet.outputs.subnetResourceId
  }
}

module stg 'buildagent.stg.bicep' = {
  name: 'stgDeploy'
  scope: rg
  params: {
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    subnetResourceId: vnet.outputs.subnetResourceId
    vmssPrincipalId: vmss.outputs.principalId
    vnetResourceId: vnet.outputs.vnetResourceId
  }
}

module kv 'buildagent.kv.bicep' = {
  name: 'kvDeploy'
  scope: rg
  params: {
    keyVaultName: keyVaultName
    subnetResourceId: vnet.outputs.subnetResourceId
    vmssPrincipalId: vmss.outputs.principalId
    vnetResourceId: vnet.outputs.vnetResourceId
  }
}
