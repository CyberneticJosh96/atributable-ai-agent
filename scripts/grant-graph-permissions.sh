#!/usr/bin/env bash
# Grants three read-only Microsoft Graph application permissions to the
# collector's managed identity. The portal can't grant Graph permissions to a
# managed identity, so this uses az rest. Permission IDs are looked up by name.
# Run as an admin who can grant app roles.

MI="<COLLECTOR-MANAGED-IDENTITY-OBJECT-ID>"
GRAPH_APP=00000003-0000-0000-c000-000000000000
GRAPH_SP=$(az ad sp show --id $GRAPH_APP --query id -o tsv)

for PERM in User.Read.All Application.Read.All RoleManagement.Read.Directory; do
  ROLE=$(az ad sp show --id $GRAPH_APP --query "appRoles[?value=='$PERM'].id" -o tsv)
  az rest --method POST \
    --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$MI/appRoleAssignments" \
    --headers "Content-Type=application/json" \
    --body "{\"principalId\":\"$MI\",\"resourceId\":\"$GRAPH_SP\",\"appRoleId\":\"$ROLE\"}"
done
