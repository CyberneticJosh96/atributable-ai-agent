# Exception register

| Exception | Risk | Production approach |
| --- | --- | --- |
| OpenAPI tool authenticates as the shared Foundry resource identity | Any agent in the resource could read the snapshots; storage can't tell agents apart | One agent per Foundry resource, or a hosted agent or tool type that authenticates as the agent identity; correlate traces until then |
| Traces store tool results (snapshot contents) | Telemetry becomes a second copy of the data | Restrict Application Insights access to match the data |
| Public network access on the Foundry resource and storage account | Endpoints reachable from the internet (Entra auth still required) | Private endpoints, public access disabled |
| Immutability retention of 1 day, unlocked | Policy could be removed; short retention | Locked policy matching the records retention schedule |
| Global Standard model deployment | Prompts may be processed outside the region | Regional or Data Zone deployment |
| Guardrail: sensitive data leakage and task drift set to annotate | Detected, not blocked | Move to block after tuning |
| Security Reader at subscription scope | Read access to all security data in the subscription | Subscription-level by design for secure score; review periodically |
| Synthetic endpoint and vulnerability data | Not real telemetry | Defender for Endpoint API with its own scoped permission |
| Key-access and shared-key policies in audit mode | Non-compliance flagged, not prevented | Deny effect once the build is stable |
