# V11 Automation Engine Blueprint

Recommended services: authentication, tenant isolation, jobs, locations, rules, messaging, compliance, analytics, audit, integrations.

Rule example:
IF job.status = incoming AND elapsed > 120 seconds THEN notify dispatcher AND offer reassignment.

Never store API secrets in Flutter. Use a secure server-side secret manager.
