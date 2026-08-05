# AI Provider Contract

The Flutter client calls Roadside X backend endpoints only. The backend may route
to an approved AI provider. Standard response fields should include:

- `request_id`
- `recommendation`
- `confidence`
- `explanation_factors`
- `requires_approval`
- `warnings`
- `source_record_ids`
- `created_at`

No AI-provider credential should be shipped in the mobile or web application.
