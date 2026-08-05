# Roadside X V14 Growth Integration Backend

## Public endpoints

- `POST /webhooks/callrail/call-started`
- `POST /webhooks/callrail/call-completed`
- `POST /webhooks/callrail/transcript-ready`
- `POST /webhooks/wordpress/lead`
- `POST /integrations/google-ads/offline-conversions`
- `GET /integrations/status`

## CallRail workflow

1. Validate the webhook and normalize the CallRail call ID.
2. Deduplicate by provider event ID and call ID.
3. Match caller phone to a customer.
4. Save attribution, tracking number, campaign, recording link, and transcript.
5. Create a call-intake record or draft job.
6. Respond quickly and process heavy work asynchronously.
7. Run a periodic API reconciliation because webhook delivery can fail.

## Google Ads workflow

1. Capture GCLID, GBRAID, or WBRAID on the website/call lead when present.
2. Store consent state and the original lead timestamp.
3. When the Roadside X job is completed and paid, create an offline conversion queue record.
4. Upload through the Google Ads API from the backend using OAuth and a developer token.
5. Include customer ID, conversion action, conversion time, currency, value, and a unique order ID.
6. Record partial failures and retry only retryable errors.

## WordPress workflow

1. WordPress sends form submissions to the protected backend.
2. Verify a shared signature or authenticated application password.
3. Normalize fields and create a Roadside X lead or draft job.
4. Optionally return a public tracking token—not an internal job ID.
5. Send status changes back to WordPress only through authenticated server-to-server calls.

## Security

- Keep API keys, OAuth secrets, refresh tokens, and webhook secrets in environment variables or a secret manager.
- Do not place credentials in Flutter, WordPress front-end JavaScript, or Git.
- Encrypt sensitive data at rest and use HTTPS.
- Use idempotency keys and provider event IDs.
- Maintain audit logs for imports, exports, retries, and user approvals.
