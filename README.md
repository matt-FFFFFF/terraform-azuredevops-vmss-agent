# VMSS Azure DevOps Agent (Linux)

This contains the Bicep template required to deploy the VMSS to Azure

To run standalone:

```bash
# base64 encode the cloud-init.yml fie
ADMINSSHPUBKEY=$(scripts/generate-random-ssh-pubkey.sh)
CLOUDINITB64=$(base64 -w0 cloud-init.yml)
RG=estf

az deployment group create \
    --resource-group $RG \
    --template-file buildagent.bicep \
    --parameters customDataBase64=$CLOUDINITB64 adminSshPubKey=$ADMINSSHPUBKEY
```

Finally, complete the setup in Azure DevOps to add the VM extension
