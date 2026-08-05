# V12 AI Backend Blueprint

Recommended protected endpoints:

- `POST /v1/ai/query` — role-scoped business questions
- `POST /v1/ai/call-intake` — extract a reviewed job draft
- `POST /v1/ai/dispatch-score` — rank eligible technicians
- `POST /v1/ai/pricing-review` — margin and authorization review
- `POST /v1/ai/reconcile` — compare jobs, invoices and partner payments
- `POST /v1/ai/forecast` — demand, staffing and inventory estimates

Every request should include tenant/company ID, authenticated user ID, role,
request ID and an auditable approval state. Secrets belong in server-side secret
storage. High-impact actions should default to human approval.
