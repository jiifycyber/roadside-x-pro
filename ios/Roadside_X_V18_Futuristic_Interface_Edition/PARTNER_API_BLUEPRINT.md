# Roadside X Partner Integration Contract (Backend Blueprint)

Recommended inbound endpoint:
POST /api/v1/partner-dispatches

Recommended outbound status endpoint:
POST /api/v1/partner-dispatches/{referenceNumber}/status

Core inbound fields:
- partner
- referenceNumber
- purchaseOrder
- customer.name
- customer.phone
- vehicle
- service
- pickupAddress
- destinationAddress
- authorizedAmount
- authorizedMiles
- notes

Core outbound statuses:
- accepted
- declined
- assigned
- en_route
- on_site
- completed
- cancelled
- invoiced
- paid

Production requirements:
- OAuth 2.0, signed webhook, mTLS, or partner-approved authentication
- Idempotency key / duplicate protection
- encrypted secrets
- request signature validation
- retry queue
- audit log
- rate limiting
- per-partner field mapping
