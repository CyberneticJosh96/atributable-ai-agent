# Evidence

Sanitized screenshots and command output. IDs are truncated to their first 4 characters; subscription, tenant, and resource names are redacted.

| File | Proves |
| --- | --- |
| 01-security-defaults.png | MFA enforced tenant-wide |
| 02-budget-alerts.png | Cost control |
| 03-policy-assignments.png | Four policies enforced |
| 04-foundry-key-auth-disabled.txt | disableLocalAuth = true |
| 05-guardrail-settings.png | Prompt injection protection on |
| 06-tracing-managed-identity.png | Tracing connected without an API key |
| 07-storage-settings.png | Key access and anonymous access off |
| 08-immutable-overwrite-blocked.png | Overwrite refused |
| 09-immutable-delete-blocked.png | Delete refused |
| 10-collector-identity.png | Managed identity on, no secrets |
| 11-collector-roles.txt | Container-scoped write; Security Reader before and after the scope fix |
| 12-graph-permissions.png | Three scoped Graph read permissions |
| 13-collector-run.png | End-to-end run succeeded |
| 14-snapshot.json | Real metrics written |
| 15-attribution-kql.png | Collector vs. human writes, and the blocked delete |
| 16-temp-role-removed.png | Only the collector holds write access |
| 17-agent-settings.png | Grounded, cited, read-only instructions |
| 18-tool-spec.png | GET-only tool, managed identity auth |
| 19-agent-denied-403.png | Denied before any role was granted |
| 20-agent-reader-role.txt | Reader on snapshots only |
| 21-grounded-answers.png | Cited answers; synthetic data disclosed |
| 22-agent-identity-blueprint.png | Agent identity; federated credential, no client secrets |
| 23-negative-tests.png | Write refused, out of scope refused, injection blocked |
| 24-trace-to-storage-correlation.png | Trace and storage log matched on file and time |
