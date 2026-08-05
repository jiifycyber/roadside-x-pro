# Roadside X V17+ Community Backend Blueprint

## Required production services
- Secure multi-tenant authentication and role-based access
- Company and technician profiles
- Feed posts, comments, reactions, shares, and bookmarks
- Groups, membership approvals, moderators, and permissions
- Direct messages, company channels, and job-specific threads
- Marketplace listings, search, moderation, and expiration
- Provider referral exchange with consent and contract checks
- Media upload, virus scanning, image/video processing, and CDN delivery
- Push notifications and email preferences
- Report, block, mute, appeal, suspension, and audit workflows

## Recommended data domains
users, companies, profiles, posts, comments, reactions, groups, group_members,
messages, conversations, marketplace_listings, referrals, reports, moderation_actions,
media_assets, notifications, verification_records, audit_events.

## Privacy boundary
Public/community content must remain separate from customer job records. Customer names,
phone numbers, addresses, vehicle identifiers, GPS history, payment data, and motor-club
authorizations are private unless an authorized workflow explicitly shares the minimum
necessary information.

## API examples
POST /v1/community/posts
GET /v1/community/feed
POST /v1/community/groups/{id}/join
POST /v1/community/messages
POST /v1/community/referrals
POST /v1/community/reports
POST /v1/community/media/presign
