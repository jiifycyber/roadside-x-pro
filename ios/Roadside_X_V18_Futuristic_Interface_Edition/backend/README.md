# Roadside X V10 Backend Blueprint

Recommended production services:
- Authentication and role claims
- REST API and signed partner webhooks
- Real-time job and technician-location streams
- Offline event reconciliation
- File/photo/signature storage
- Notification worker
- Receipt and invoice delivery
- Payment and subscription webhooks
- Audit logging and backups

Secrets belong in server environment variables or a managed secret vault, never in Flutter.
