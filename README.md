# Azure Policy

Implementing governance of resources with Azure Policy.

Create the baseline resources:

```sh
terraform init
terraform apply -auto-approve
```

Next sections will build upon this.

## Tags

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

## General info

Effects:

- Deny
- Append
- Modify
- DeployIfNotExists
