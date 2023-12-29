# Azure Policy

Implementing governance of resources with Azure Policy. Several Policy samples can be found in the [Azure/Community-Policy][2] repository.

Create the baseline resources:

```sh
terraform init
terraform apply -auto-approve
```

Next sections will build upon this.

## Simple tags policy

Create the tags policy:

> You may optionally add policy parameters

```sh
az policy definition create --name CostCenter --rules @policies/costcenter/rules.json
```

Replace the `SUBSCRIPTION_ID` placeholder and execute the following to create the initiative:

> Initiative can have groups, initiative parameters, and also policy parameters.

```sh
az policy set-definition create -n requireCostCenterTag \
    --definitions '[ { "policyDefinitionId": "/subscriptions/SUBSCRIPTION_ID/providers/Microsoft.Authorization/policyDefinitions/CostCenter" } ]'
```

Assign the initiative:

> Assignments can have exclusions, enforcement (enabled/disabled), and most importantly Remediation.
> 
> On Preview, there's also resource selectors and overrides.

```sh
az policy assignment create -n CostCenter --policy-set-definition requireCostCenterTag \
    --scope /subscriptions/SUBSCRIPTION_ID/resourceGroups/rg-bigfactory
```

## Effects

Create the base resource group:

```sh
az group create -n rg-policy-sandbox -l brazilsouth
```

To force a policy scan:

```sh
az policy state trigger-scan --resource-group "rg-policy-sandbox"
```

Load the subscription id for the following commands.

```sh
subscriptionId=$(az account show --query id -o tsv)
```

Get your public IP in case of customization of parameters:

```sh
curl ipinfo.io/ip
```

When creating a policy, identify the correct [Resource Provider mode][1]:

> The **mode** determines which resource types are evaluated for a policy definition. The supported modes are:
> 
> - `all`: evaluate resource groups, subscriptions, and all resource types
> - `indexed`: only evaluate resource types that support tags and location


### `Append`

Create the policy and assign the policy:

```sh
az policy definition create --name AppendSample \
    --rules @policies/effects/append-rules.json \
    --params @policies/effects/append-params.json

az policy assignment create -n AppendRuleToStorage --policy AppendSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```

Create the storage account:

```sh
az storage account create \
    --name sandbox \
    --resource-group rg-policy-sandbox \
    --location brazilsouth \
    --sku Standard_LRS \
    --allow-blob-public-access false \
    --default-action Deny \
    --bypass AzureServices Logging Metrics \
    --tags PolicySandbox
```

### `Audit`

Audit effect sample:

```sh
az policy definition create --name AuditSample \
    --rules @policies/effects/audit-rules.json

az policy assignment create -n AuditSample --policy AuditSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```

### `AuditIfNotExists`

```sh
az vm create \
  --resource-group rg-policy-sandbox \
  --location brazilsouth \
  --name vm-debian \
  --image Debian11 \
  --admin-username debianadmin \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --size Standard_B1s
```

Set the policy:

```sh
az policy definition create --name AuditIfNotExistsSample \
    --rules @policies/effects/auditIfNotExists-rules.json

az policy assignment create -n AuditIfNotExistsSample --policy AuditIfNotExistsSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```

### `Deny`

Set the `Deny` policy:

```sh
az policy definition create --name DenySample \
    --rules @policies/effects/deny-rules.json

az policy assignment create -n DenySample --policy DenySample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```

Try to create the storage. This command should be denied by the policy:

```sh
az storage account create \
    --name sandbox \
    --resource-group rg-policy-sandbox \
    --location brazilsouth \
    --sku Standard_LRS \
    --allow-blob-public-access false
```

### `DenyAction`

Set the `DenyAction` policy:

```sh
az policy definition create --name DenyActionSample \
    --rules @policies/effects/denyAction-rules.json

az policy assignment create -n DenyActionSample --policy DenyActionSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```

Create the storage, or tag one existing with a `environment=prod` tag:

```sh
az storage account create \
    --name sandbox \
    --resource-group rg-policy-sandbox \
    --location brazilsouth \
    --sku Standard_LRS \
    --allow-blob-public-access false \
    --tags environment=prod
```

### `DeployIfNotExists`

Copied from the [functionapp-enforce-https-only-dine][3] sample.

```sh
az policy definition create --name DeployIfNotExistsSample \
    --rules @policies/effects/DeployIfNotExists-rules.json \
    --params @policies/effects/DeployIfNotExists-params.json

az policy assignment create -n DeployIfNotExistsSample --policy DeployIfNotExistsSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default \
    --mi-system-assigned \
    --location brazilsouth
```

Create the function and check that HTTPS Only will be set to `true` after the deployment is complete.

```sh
az functionapp create -n funcappdeploypolicy -g rg-policy-sandbox \
    --storage-account <some storage> \
    --consumption-plan-location brazilsouth \
    --runtime dotnet \
    --functions-version 4 \
    --https-only false
```


[1]: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#resource-manager-modes
[2]: https://github.com/Azure/Community-Policy
[3]: https://github.com/Azure/Community-Policy/blob/53c5f27699d149eeb2f554e7f62b2dd6b5ce1817/Policies/App%20Service/functionapp-enforce-https-only-dine/azurepolicy.json
