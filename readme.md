# Attributable AI Agent

An AI agent on Microsoft Foundry that answers security questions from tamper-proof data, holds no secrets, can't write anything, and leaves a trail tying every read back to it. Built in a personal Azure trial.

<img width="1520" height="784" alt="architecture" src="https://github.com/user-attachments/assets/cdef7af1-3dc0-4735-af29-388361302c29" />

## Project parts

| Part | What it shows | Write-up |
| --- | --- | --- |
| **1. Attributable agent** | A Foundry agent with its own Entra identity, reading tamper-proof data through a GET-only tool. Finding: the tool authenticated as the shared Foundry identity, so attribution needed trace and storage log correlation. | This page |
| **2. AI gateway** | APIM in front of the model: certificate based Entra tokens, `validate-jwt` with audience and role checks, per identity rate and token limits, keyless managed identity to Foundry, and logs that record why every call was allowed or denied. | [docs/part2-ai-gateway.md](docs/part2-ai-gateway.md) |

**Part 2 in one line:** the gateway sends the same 401 to every rejected caller, but the logs record exactly why (`TokenNotPresent`, `TokenInvalidAudience`, `OpenAITokenLimitExceeded`) and which verified app made every allowed call.

## The problem
AI agents are starting to touch security data. The hard question isn't whether they answer well; it's whose identity acted, what it was allowed to do, and whether anyone can prove it afterwards.

## What it does
- **Collector:** a Logic App pulls identity and posture metrics from Microsoft Graph and Defender for Cloud weekly, under a managed identity. No secrets.
- **Snapshot store:** each run writes a timestamped JSON snapshot to an immutable container. Overwrite and delete are refused.
- **Agent:** a published Foundry agent with its own Entra agent identity answers questions from the snapshots, cites the file and timestamp, and discloses synthetic data.
- **Attribution:** storage logs and agent traces together tie every read to the specific agent that made it.

## Security controls
| Control | Why | Evidence |
| --- | --- | --- |
| Managed identity collector, container-scoped write | No stored credentials; can't reach anything else | [10](evidence/10-collector-identity.png), [11a](evidence/11a-collector-storage-role.png) |
| Three scoped Graph read permissions | Least privilege over Directory.Read.All | [12](evidence/12-graph-permissions.png) |
| Immutable snapshots, shared keys off | Tamper-proof, identity-only access | [07c](evidence/07c-immutability-policy.png), [08](evidence/08-immutable-overwrite-blocked.png), [09](evidence/09-immutable-delete-blocked.png) |
| GET-only agent tool, read access to one container | The agent can't request or perform a write | [18](evidence/18-tool-spec.png), [19](evidence/19-agent-denied-403.png) |
| Agent identity with federated credential, no secrets | Per-agent non-human identity | [22a](evidence/22a-agent-identity-created.png), [22b](evidence/22b-blueprint-federated-no-secrets.png) |
| Prompt injection guardrail | Blocks instructions hidden in data | [05a](evidence/05a-guardrail-controls.png) |
| Foundry API keys disabled; tracing through a managed identity | Every call identity-based and recorded | [04](evidence/04-foundry-key-auth-disabled.png), [06a](evidence/06a-tracing-managed-identity.png) |
| Azure Policy, budget, MFA | Governance enforced | [01](evidence/01-security-defaults.png), [02](evidence/02-budget-alerts.png), [03](evidence/03-policy-assignments.png) |

## What the agent can't do
| Test | Result | Evidence |
| --- | --- | --- |
| Read before being granted access | Denied, 403, logged | [19](evidence/19-agent-denied-403.png) |
| Delete a file, change a value | Refused; no write path exists | [23a](evidence/23a-write-refused.png) |
| Answer beyond the data | "That isn't in the snapshot data" | [23b](evidence/23b-out-of-scope.png) |
| Follow instructions planted in a snapshot | Blocked by the guardrail | [23c](evidence/23c-injection-blocked.png) |
| (detail) Where the injection was caught | The file was read (GetBlob 200), so the guardrail blocked it on the tool response, not before the read | [23d](evidence/23d-injection-file-read-log.png) |

## Framework mapping
| Framework | Item | How this project addresses it |
| --- | --- | --- |
| OWASP Top 10 for LLM Applications | LLM01 Prompt Injection | Indirect prompt injection guardrail; planted injection blocked ([23c](evidence/23c-injection-blocked.png)) |
| OWASP Top 10 for LLM Applications | LLM06 Excessive Agency | GET-only tool and read-only role; write requests refused ([18](evidence/18-tool-spec.png), [23a](evidence/23a-write-refused.png)) |
| OWASP Top 10 for LLM Applications | LLM02 Sensitive Information Disclosure | Sensitive data leakage guardrail; synthetic data disclosed ([05b](evidence/05b-guardrail-sensitive-data.png), [21b](evidence/21b-synthetic-disclosed.png)) |
| Zero Trust | Verify explicitly | API keys disabled; every call authenticates with an Entra identity ([04](evidence/04-foundry-key-auth-disabled.png)) | Part 2 closes this gap at the gateway: every call is attributed to a verified app identity in one log table ([docs/part2-ai-gateway.md](docs/part2-ai-gateway.md)).
| Zero Trust | Least privilege | Container-scoped roles; three scoped Graph permissions ([11a](evidence/11a-collector-storage-role.png), [12](evidence/12-graph-permissions.png)) |
| Zero Trust | Assume breach | Immutable storage and identity-attributed logs ([08](evidence/08-immutable-overwrite-blocked.png), [15](evidence/15-attribution-kql.png)) |
| NIST AI RMF | Govern | Exception register with documented risk acceptance ([docs](docs/Exception-register.md)) |
| NIST AI RMF | Measure | Negative tests for access, writes, scope, and injection ([agent/tests.md](agent/tests.md)) |
| NIST AI RMF | Manage | Identified the shared-identity attribution gap and documented the mitigation |
| `policies/` | Part 2 APIM inbound policy (IDs replaced with placeholders) |
| `images/part2/` | Part 2 sanitized screenshots |

## The finding
Publishing gave the agent its own Entra identity with a federated credential and no secrets. But the OpenAPI tool still authenticated to storage as the shared Foundry resource identity, so storage logs alone can't tell agents apart. Per-agent attribution comes from matching Foundry traces to storage logs on file and time ([24a](evidence/24a-storage-read-log.png), [24b](evidence/24b-trace-tool-output.png)). See [docs/Exception-register.md](docs/Exception-register.md).

## Repo contents
| Path | What it is |
| --- | --- |
| `collector/workflow.json` | Logic App definition (managed identity auth throughout) |
| `agent/` | Agent instructions, GET-only tool spec, tests and results |
| `scripts/` | CLI used to grant permissions and harden Foundry; Part 2 token script and test runner || `queries/attribution.kql` | The queries behind the attribution evidence |
| `data/` | Synthetic data and the prompt injection test file |
| `docs/` | Lessons learned, exception register |
| `evidence/` | Sanitized screenshots, indexed in [evidence/README.md](evidence/README.md) |

## Limitations
- Personal trial tenant; endpoint and vulnerability data is synthetic and labeled.
- Public network access is enabled for the proof of concept.
- Built through the portal and CLI; infrastructure as code is on the roadmap.

## Lessons learned
- **An agent identity existing doesn't mean every tool uses it.** Check which identity actually reaches your data.
- **Verify scope after every role assignment.** A portal page said "This resource," and a role landed on the wrong scope; `az role assignment list` caught it ([11b](evidence/11b-security-reader-wrong-scope.png) → [11c](evidence/11c-security-reader-scope-fixed.png)).
- **Turn on logging before testing controls,** or the evidence doesn't exist.
- **Tracing turns telemetry into a data store.** Traces captured full tool results, so Application Insights needs the same access control as the data.

Full list: [docs/Lessons-Learned.md](docs/Lessons-Learned.md)

## Attribution
See [ATTRIBUTION.md](ATTRIBUTION.md). Planning and documentation were assisted by Claude (Anthropic); all configuration, testing, and verification were done by me.
