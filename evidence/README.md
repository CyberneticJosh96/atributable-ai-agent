# Evidence

Sanitized screenshots from a personal Azure trial tenant. Object IDs are truncated to their first 4 characters; subscription, tenant, resource group, and resource names are redacted.

## Tenant and governance
| File | Proves |
| --- | --- |
| 01-security-defaults.png | MFA enforced tenant-wide |
| 02-budget-alerts.png | Cost control: monthly budget with 25/50/90% alerts |
| 03-policy-assignments.png | Four Azure Policies enforced |

## Foundry hardening
| File | Proves |
| --- | --- |
| 04-foundry-key-auth-disabled.png | API key auth disabled (`disableLocalAuth = true`) |
| 05a-guardrail-controls.png | Jailbreak and indirect prompt injection set to block |
| 05b-guardrail-sensitive-data.png | Sensitive data leakage (PII) protection |
| 06a-tracing-managed-identity.png | Tracing connected through the project managed identity, not an API key |
| 06b-tracing-connected.png | Application Insights connected to the project |
| 06c-tracing-role.png | Project identity holds Monitoring Metrics Publisher on that resource only |

## Immutable snapshot store
| File | Proves |
| --- | --- |
| 07a-storage-review.png | Storage account configuration |
| 07b-storage-security-settings.png | Account key access and anonymous access off, TLS 1.2 |
| 07c-immutability-policy.png | Time-based retention policy on the container; shared key disabled |
| 08-immutable-overwrite-blocked.png | Overwrite refused by policy |
| 09-immutable-delete-blocked.png | Delete refused by policy |

## Collector
| File | Proves |
| --- | --- |
| 10-collector-identity.png | System-assigned managed identity on, no secrets |
| 11a-collector-storage-role.png | Write role scoped to the snapshots container only |
| 11b-security-reader-wrong-scope.png | Security Reader landed on the storage account by mistake |
| 11c-security-reader-scope-fixed.png | Security Reader corrected to subscription scope |
| 12-graph-permissions.png | Three scoped Graph read permissions, application type |
| 13-collector-run.png | End-to-end run; secure score call shows the Forbidden before the fix |
| 14-snapshot.png | Real metrics written as a timestamped snapshot |
| 15-attribution-kql.png | Collector vs. human writes, and the 409 blocked delete |
| 16-temp-role-removed.png | Temporary user role removed; only the collector holds write access |

## Agent
| File | Proves |
| --- | --- |
| 17-agent-settings.png | Grounded, cited, read-only instructions; snapshot_reader tool attached |
| 18-tool-spec.png | OpenAPI tool with managed identity auth to storage |
| 19-agent-denied-403.png | Denied (403) before any data role was granted |
| 21a-grounded-answer.png | Correct answer, cited by file and timestamp |
| 21b-synthetic-disclosed.png | Synthetic data flagged as not real, cited |
| 21c-tool-call-trace.png | Tool call and response captured in the trace |
| 22a-agent-identity-created.png | Publishing created an agent identity and blueprint |
| 22b-blueprint-federated-no-secrets.png | Blueprint uses a federated credential; zero client secrets |

## Negative tests
| File | Proves |
| --- | --- |
| 23a-write-refused.png | Asked to delete and modify data: refused |
| 23b-out-of-scope.png | Asked about data it doesn't have: "That isn't in the snapshot data" |
| 23c-injection-blocked.png | Planted prompt injection blocked by the guardrail |
| 23d-injection-file-read-log.png | The injection file was read (GetBlob 200), so the block happened on the tool response |

## Attribution
| File | Proves |
| --- | --- |
| 24a-storage-read-log.png | Storage log of the agent's read of a specific snapshot |
| 24b-trace-tool-output.png | Foundry trace of the same tool call; matched to 24a on file name |
