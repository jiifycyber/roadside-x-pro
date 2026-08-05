# Roadside X V13 Voice Backend Blueprint

## Required production services
- Public HTTPS backend with secure secret storage
- Voice/telephone provider with inbound-call webhooks and call transfer
- Speech-to-text or real-time transcription
- AI model endpoint for structured intake and approved responses
- Cloud database for calls, transcripts, jobs, users, and audit logs
- SMS/email provider for confirmations

## Suggested endpoints
- POST /api/v1/voice/incoming
- POST /api/v1/voice/transcript
- POST /api/v1/voice/escalate
- POST /api/v1/voice/call-ended
- POST /api/v1/ai/extract-job
- POST /api/v1/jobs/drafts/:id/approve

## Mandatory safeguards
- Announce automated-agent use when required
- Obtain recording/transcription consent where required
- Immediately escalate emergencies, threats, injuries, accidents, and uncertain safety situations
- Require human approval for pricing, refunds, cancellations, and high-risk dispatches
- Encrypt recordings and transcripts; apply retention and deletion policies
- Never expose voice-provider or AI credentials inside Flutter
