# Attributable AI Agent

An AI agent on Microsoft Foundry that answers security questions from tamper proof data, holds no secrets, can't write anything, and leaves a trail tying every read back to it. Built in a personal Azure trial.

<img width="1520" height="784" alt="architecture" src="https://github.com/user-attachments/assets/cdef7af1-3dc0-4735-af29-388361302c29" />


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
| Managed identity collector, container-scoped write | No stored credentials; can't reach anything else | [10](evidence/10-collector-identity.png), [11](evidence/11-collector-roles.txt) |
| Three scoped Graph read permissions | Least privilege over Directory.Read.All | [12](evidence/12-graph-permissions.png) |
| Immutable snapshots, shared keys off | Tamper-proof, identity-only access | [08](evidence/08-immutable-overwrite-blocked.png), [09](evidence/09-immutable-delete-blocked.png) |
| GET-only agent tool, Reader role on one container | The agent can't request or perform a write | [18](evidence/18-tool-spec.png), [20](evidence/20-agent-reader-role.txt) |
| Agent identity with federated credential, no secrets | Per-agent non-human identity | [22](evidence/22-agent-identity-blueprint.png) |
| Prompt injection guardrail | Blocks instructions hidden in data | [05](evidence/05-guardrail-settings.png) |
| Foundry API keys disabled; tracing through a managed identity | Every call identity-based and recorded | [04](evidence/04-foundry-key-auth-disabled.txt), [06](evidence/06-tracing-managed-identity.png) |
| Azure Policy, budget, MFA | Governance enforced | [01](evidence/01-security-defaults.png), [03](evidence/03-policy-assignments.png) |

## What the agent can't do
| Test | Result | Evidence |
| --- | --- | --- |
| Read before being granted access | Denied, 403, logged | [19](evidence/19-agent-denied-403.png) |
| Delete a file, change a value | Refused; no write path exists | [23](evidence/23-negative-tests.png) |
| Answer beyond the data | "That isn't in the snapshot data" | [23](evidence/23-negative-tests.png) |
| Follow instructions planted in a snapshot | Blocked by the guardrail | [23](evidence/23-negative-tests.png) |

## The finding
Publishing gave the agent its own Entra identity with a federated credential and no secrets. But the OpenAPI tool still authenticated to storage as the shared Foundry resource identity, so storage logs alone can't tell agents apart. Per-agent attribution comes from matching Foundry traces to storage logs on file and time ([24](evidence/24-trace-to-storage-correlation.png)). See [docs/exception-register.md](docs/Exception-register.md).

## Repo contents
| Path | What it is |
| --- | --- |
| `collector/workflow.json` | Logic App definition (managed identity auth throughout) |
| `agent/` | Agent instructions, GET-only tool spec, tests and results |
| `scripts/` | CLI used to grant permissions and harden Foundry |
| `queries/attribution.kql` | The queries behind the attribution evidence |
| `data/` | Synthetic data and the prompt injection test file |
| `docs/` | Lessons learned, exception register, architecture |
| `evidence/` | Sanitized screenshots and command output |

## Limitations
- Personal trial tenant; endpoint and vulnerability data is synthetic and labeled.
- Public network access is enabled for the proof of concept.
- Built through the portal and CLI; infrastructure as code is on the roadmap.

## Lessons learned
- **An agent identity existing doesn't mean every tool uses it.** Check which identity actually reaches your data.
- **Verify scope after every role assignment.** A portal page said "This resource," and a role landed on the wrong scope; `az role assignment list` caught it.
- **Turn on logging before testing controls,** or the evidence doesn't exist.
- **Tracing turns telemetry into a data store.** Traces captured full tool results, so Application Insights needs the same access control as the data.

Full list: [docs/lessons-learned.md](docs/Lessons-Learned.md)

## Attribution
See [ATTRIBUTION.md](ATTRIBUTION.md). Planning and documentation were assisted by Claude (Anthropic); all configuration, testing, and verification were done by me.
