# V14 Connector Contract

Every connector must implement:

- `testConnection()`
- `receiveEvent(payload)`
- `normalizeLead(payload)`
- `deduplicate(externalId)`
- `createDraftJob(lead)`
- `syncStatus(job)`
- `queueConversion(job)`
- `retryFailures()`
- `healthCheck()`

Normalized lead fields:

- external ID
- source system
- caller/customer name
- phone
- email
- service type
- vehicle
- address and coordinates
- campaign/source/medium
- GCLID/GBRAID/WBRAID
- recording URL
- transcript
- consent state
- received timestamp
