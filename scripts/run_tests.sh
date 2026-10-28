#!/bin/bash
# Part 2 test runner: one good call, two 401 negative tests, then a loop that trips the token limit.
# Set these before running:
#   TENANT_ID, CLIENT_ID, GATEWAY_API_ID (the gateway app registration's client ID),
#   GATEWAY_URL (https://<apim-name>.azure-api.net), DEPLOYMENT (model deployment name)
# Expects client.key / client.crt in ~/p2-certs and p2_get_token.py alongside this script.
set -u
cd ~/p2-certs || exit 1
source .venv/bin/activate
export CERT_THUMBPRINT=$(openssl x509 -in client.crt -noout -fingerprint -sha1 | sed 's/.*=//; s/://g')
URL="$GATEWAY_URL/foundry/openai/deployments/$DEPLOYMENT/chat/completions?api-version=2025-03-01-preview"
BODY='{"messages":[{"role":"user","content":"Explain OAuth in two sentences."}],"max_completion_tokens":500}'

# Wrong-audience token: same app and certificate, issued for Azure Resource Manager
API_APP_ID_URI="https://management.azure.com" python3 p2_get_token.py > /dev/null && mv token.txt wrong-aud-token.txt
API_APP_ID_URI="api://$GATEWAY_API_ID" python3 p2_get_token.py > /dev/null

curl -sS -o /dev/null -w "good:      HTTP %{http_code}\n" -X POST "$URL" -H "Authorization: Bearer $(cat token.txt)" -H "Content-Type: application/json" -d "$BODY"
curl -sS -o /dev/null -w "no token:  HTTP %{http_code}\n" -X POST "$URL" -H "Content-Type: application/json" -d "$BODY"
curl -sS -o /dev/null -w "wrong aud: HTTP %{http_code}\n" -X POST "$URL" -H "Authorization: Bearer $(cat wrong-aud-token.txt)" -H "Content-Type: application/json" -d "$BODY"
for i in 1 2 3 4; do
  curl -sS -o /dev/null -w "loop $i:    HTTP %{http_code}\n" -X POST "$URL" -H "Authorization: Bearer $(cat token.txt)" -H "Content-Type: application/json" -d "$BODY"
done
