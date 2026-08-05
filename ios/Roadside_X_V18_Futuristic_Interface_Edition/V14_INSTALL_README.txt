ROADSIDE X V14 — CALLRAIL + GOOGLE ADS + WORDPRESS

1. Back up the existing lib folder.
2. Copy this package's lib folder into the Flutter project root.
3. Run:
   flutter clean
   flutter pub get
   flutter run -d chrome

The V14 Growth Integrations page supports local configuration, test CallRail calls,
test WordPress forms, unified lead attribution, and offline conversion queue demos.

For live operation:
- Deploy the backend endpoints described in backend/V14_GROWTH_INTEGRATION_BACKEND.md.
- Configure CallRail webhooks/API credentials on the backend.
- Configure Google Ads OAuth, developer token, customer ID, and conversion action.
- Install/customize the included WordPress plugin and send forms to the backend.
- Never put production secrets inside Flutter.
