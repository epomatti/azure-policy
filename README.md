# Azure Policy

Implementing governance of resources with Azure Policy.

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

```sh
subscriptionId=$(az account show --query id -o tsv)
```

This example will demonstrate several policy effects

```sh
curl ipinfo.io/ip
```

When creating a policy, identify the correct [Resource Provider mode][1]:

> The **mode** determines which resource types are evaluated for a policy definition. The supported modes are:
> 
> - `all`: evaluate resource groups, subscriptions, and all resource types
> - `indexed`: only evaluate resource types that support tags and location

Base storage creation sample:

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

### Append

Create the policy:

```sh
az policy definition create --name AppendSample --rules @policies/effects/append.json

az policy assignment create -n AppendRuleToStorage --policy FullSample \
    --scope "/subscriptions/$subscriptionId/resourceGroups/rg-policy-sandbox" \
    --enforcement-mode Default
```




[1]: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#resource-manager-modes
