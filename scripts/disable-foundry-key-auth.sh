#!/usr/bin/env bash
# Disables API key (local) authentication on the Foundry resource so every
# call must use a Microsoft Entra identity, then verifies the setting.

RG="<RESOURCE-GROUP>"
FOUNDRY="<FOUNDRY-RESOURCE-NAME>"

az resource update \
  --resource-group "$RG" \
  --name "$FOUNDRY" \
  --resource-type "Microsoft.CognitiveServices/accounts" \
  --set properties.disableLocalAuth=true

# Expect: true
az resource show \
  --resource-group "$RG" \
  --name "$FOUNDRY" \
  --resource-type "Microsoft.CognitiveServices/accounts" \
  --query properties.disableLocalAuth
