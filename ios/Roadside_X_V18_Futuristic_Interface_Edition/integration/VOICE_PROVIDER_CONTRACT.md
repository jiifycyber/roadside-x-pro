# Voice Provider Connector Contract

A connector must support:
1. Inbound call notification
2. Caller ID and called number
3. Streaming or completed transcript events
4. DTMF and speech input
5. Human transfer
6. Call termination
7. Recording URL or secure media reference when enabled
8. Webhook signature verification
9. Idempotency keys and retry handling
10. Call status events

Secrets belong on the backend, never in lib/.
