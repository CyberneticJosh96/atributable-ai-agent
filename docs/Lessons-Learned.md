# Lessons learned

| What happened | Lesson |
| --- | --- |
| A role assignment page said "This resource," and Security Reader landed on the storage account instead of the subscription. The collector got a 403 | Verify scope after every assignment. `az role assignment list` caught it in seconds |
| The agent had its own published identity, but storage logs showed the Foundry resource identity on every read | An agent identity existing doesn't mean every tool uses it. Check which identity actually reaches the resource |
| The first call was denied, and the log named the identity that tried | Let a denial tell you who to grant. Read the identity from the evidence |
| Tamper tests ran before storage logging was on, so the first denials were never recorded | Turn on logging before testing controls |
| Traces store the tool's full result, including snapshot contents | Tracing turns telemetry into a data store. Application Insights needs the same access control as the data |
| The first model couldn't use the OpenAPI tool | Check tool support before choosing an agent's model |
| The tool failed generically until the XML and JSON response types were declared | Declare response types in OpenAPI specs for non-JSON APIs |
| Logs looked wrong until UTC timestamps and the 5–15 minute delay were accounted for | Read log times in UTC, and wait for ingestion |
| Foundry created a resource group, resource, and project on its own the moment the portal opened | Platforms provision things you didn't ask for. Inventory before building |
| The playground failed with "insufficient quota" at the lowest tokens-per-minute limit | TPM limits throughput, not cost. The budget is the cost control |
| The portal can't grant Graph permissions to a managed identity | Use `az rest`, looking up each permission ID by name |
| The secure score went 403, then 404 | A 404 after a permission fix means authorized, but no data yet |
