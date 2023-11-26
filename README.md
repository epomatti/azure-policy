# Azure Policy

Implementing governance of resources with Azure Policy.

Create the baseline resources:

```sh
terraform init
terraform apply -auto-approve
```

Next sections will build upon this.

Effects:

- Deny
- Append
- Modify
- DeployIfNotExists

## Tags

Create the tags policy:

```sh
az policy definition create --name CostCenter --rules @policies/costcenter/rules.json
```



```sh
az policy set-definition create -n readOnlyStorage \
            --definitions '[ { \"policyDefinitionId\": \"/subscriptions/mySubId/providers/ \
                Microsoft.Authorization/policyDefinitions/storagePolicy\" } ]'
```
Try creating 


