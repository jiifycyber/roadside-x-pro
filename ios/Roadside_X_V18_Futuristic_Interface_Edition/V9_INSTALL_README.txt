ROADSIDE X V9 — MOTOR CLUB & INSURANCE INTEGRATION HUB

INSTALL
1. Back up your current Flutter project's lib folder.
2. Replace it with this package's lib folder.
3. Confirm the dependencies in PUBSPEC_ADDITIONS.yaml are in pubspec.yaml.
4. Run:
   flutter clean
   flutter pub get
   flutter run -d chrome

WHAT WORKS LOCALLY
- Partner connection profiles
- Manual dispatch import
- Test/sandbox dispatch generator
- Incoming call inbox
- Accept/decline workflow
- Technician assignment
- Partner job status progression
- Purchase-order and authorization tracking
- Duplicate-dispatch protection
- Billing and payment reconciliation queue
- JSON payload export
- Connection endpoint testing
- Persistent local storage
- Integration activity logs

LIVE CONNECTION REQUIREMENTS
A live connection to Traxero-compatible systems, Agero/Swoop, Allstate, HONK, NSD, Road America, insurance companies, fleets, dealerships, or rental companies requires that organization to provide approval, API documentation, credentials, webhooks, or a supported dispatch feed.

SECURITY
Do not place raw production API secrets inside Flutter source code. Use a secure backend or cloud secret manager. The Flutter app should call your backend, and your backend should communicate with the partner.
