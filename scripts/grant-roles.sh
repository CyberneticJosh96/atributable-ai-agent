#!/usr/bin/env bash
# Role assignments for the collector and the agent, each at the narrowest scope.
# Always verify scope afterwards: a portal assignment once landed on the
# storage account instead of the subscription, and only the list command caught it.

SUB=$(az account show --query id -o tsv)
RG="<RESOURCE-GROUP>"
STORAGE="<STORAGE-ACCOUNT>"
CONTAINER_SCOPE="/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.Storage/storageAccounts/$STORAGE/blobServices/default/containers/snapshots"

COLLECTOR_MI="<COLLECTOR-MANAGED-IDENTITY-OBJECT-ID>"
FOUNDRY_MI="<FOUNDRY-RESOURCE-MANAGED-IDENTITY-OBJECT-ID>"

# Collector: write snapshots, container only
az role assignment create --assignee-object-id "$COLLECTOR_MI" --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" --scope "$CONTAINER_SCOPE"

# Collector: read secure score, subscription scope
az role assignment create --assignee-object-id "$COLLECTOR_MI" --assignee-principal-type ServicePrincipal \
  --role "Security Reader" --scope "/subscriptions/$SUB"

# Agent tool (authenticates as the Foundry resource identity): read snapshots, container only
az role assignment create --assignee-object-id "$FOUNDRY_MI" --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Reader" --scope "$CONTAINER_SCOPE"

# Verify
az role assignment list --assignee "$COLLECTOR_MI" --all -o table
az role assignment list --assignee "$FOUNDRY_MI" --all -o table
