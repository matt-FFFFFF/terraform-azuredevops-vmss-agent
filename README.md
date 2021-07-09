# VMSS Azure DevOps Agent (Linux)

This contains the Bicep template required to deploy the VMSS to Azure

To run standalone:

```bash
# Generate a random SSH public key, discarding the private key
ADMINSSHPUBKEY=$(scripts/generate-random-ssh-pubkey.sh)

# base64 encode the cloud-init.yml fie
CLOUDINITB64=$(base64 -w0 cloud-init.yml)

# Destination subscription id
SUBSCRIPTIONID=00000000-0000-0000-0000-000000000000

# Destination region
LOCATION=westeurope

# Resource naming
RESOURCEGROUPNAME=myrg
KEYVAULTNAME=mykv
STORAGEACCOUNTNAME=mystg


az deployment sub create \
    --subscription $SUBSCRIPTIONID \
    --location $LOCATION \
    --template-file bicep/buildagent.bicep \
    --parameters customDataBase64=$CLOUDINITB64 \
                 adminSshPubKey=$ADMINSSHPUBKEY \
                 resourceGroupName=$RESOURCEGROUPNAME \
                 keyVaultName=$KEYVAULTNAME \
                 storageAccountName=$STORAGEACCOUNTNAME
```

Finally, complete the setup in Azure DevOps to add the VM extension
