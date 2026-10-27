# DataNaija Flutter App

A polished Flutter mobile application built from the DataNaija HTML/React prototype.

## What it is

DataNaija is a Nigerian VTU (Virtual Top-Up) frontend app for:
- Buying mobile data on MTN, Airtel, Glo, and 9mobile
- Buying airtime (placeholder — "coming soon" notice matches prototype)
- Funding a wallet via bank transfer (after KYC) or card/USSD
- Viewing and searching transaction history
- Managing a profile, security settings, referrals, KYC, and notifications

**Frontend only.** No real network calls are made. Purchases, funding, and KYC verification are simulated locally. The architecture is intentionally structured to accept a real backend later without rewriting screens.

---

## Screens implemented

| Screen | Route / Tab |
|---|---|
| Splash | `/` |
| Onboarding (2-slide) | `/onboarding` |
| Sign In | `/signin` |
| Sign Up | `/signup` |
| Home (dashboard) | `/main` → tab 0 |
| Buy Data – Step 1 (network + phone) | `/main` → tab 1 |
| Buy Data – Step 2 (bundle select) | `/bundle` |
| Buy Data – Step 3 (review) | `/review` |
| Processing spinner | `/processing` |
| Purchase success | `/success` |
| Transactions (search + filter) | `/main` → tab 2 |
| Transaction detail | `/transaction-detail` |
| Profile | `/main` → tab 3 |
| Fund Wallet | `/fund` |
| Notifications | `/notifications` |
| Help & Support (FAQ accordion + contact) | `/help` |
| KYC Verification (BVN/NIN) | `/kyc` |
| Referral program | `/referral` |
| Security settings | `/security` |

---

## Project structure

```
lib/
  main.dart              # App entry point + route table
  core/
    app_colors.dart      # All design tokens (extracted from prototype CSS)
    app_theme.dart       # MaterialApp ThemeData
    app_state.dart       # Global ChangeNotifier state
    models.dart          # Transaction, Network, DataPlan, etc.
    sample_data.dart     # Seed data (networks, bundles, transactions, FAQs)
  widgets/
    dn_button.dart       # DnPrimaryButton, DnOutlinedButton, DnTextButton
    dn_card.dart         # DnCard container
    dn_chip.dart         # DnChip (filter / selection chip)
    dn_status_pill.dart  # Transaction status badge
    step_indicator.dart  # 3-step progress indicator
    toast.dart           # showDnToast overlay helper
    tx_row.dart          # Transaction list row
    wallet_card.dart     # Gradient wallet balance card
  screens/
    splash_screen.dart
    onboarding_screen.dart
    signin_screen.dart
    signup_screen.dart
    main_scaffold.dart          # IndexedStack + bottom nav
    home_screen.dart
    transactions_screen.dart
    transaction_detail_screen.dart
    fund_wallet_screen.dart
    notifications_screen.dart
    profile_screen.dart
    processing_screen.dart
    success_screen.dart
    help_screen.dart
    kyc_screen.dart
    referral_screen.dart
    security_screen.dart
    buy_data/
      buy_data_screen.dart      # Step 1
      bundle_select_screen.dart # Step 2
      review_screen.dart        # Step 3
test/
  widget_test.dart       # Smoke test: app launches + splash renders
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `google_fonts ^6.2.1` | Plus Jakarta Sans typeface (matches prototype) |
| `provider ^6.1.2` | Lightweight ChangeNotifier state management |
| `cupertino_icons ^1.0.8` | Default Flutter icon set |

---

## Running the app

**Prerequisites:** Flutter SDK ≥ 3.13 with Android/iOS toolchain configured.

```bash
cd data_naija
flutter pub get
flutter run          # connect a device or start an emulator first
```

**Build a debug APK:**
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Checks performed

| Check | Result |
|---|---|
| `flutter pub get` | ✅ |
| `flutter analyze` | ✅ 0 issues |
| `flutter test` | ✅ 1/1 passed |
| `flutter build apk --debug` | ✅ APK produced |

---

## Known limitations / not implemented

- **Airtime purchase** — shows "coming soon" toast, matching the prototype placeholder.
- **Biometric authentication** — the sign-in fingerprint button and Security toggle show a demo toast/simulate the flow; real `local_auth` integration requires backend auth.
- **Wallet screen** (standalone `/wallet` route in prototype) — the wallet balance is accessible directly from Home and Fund Wallet; a dedicated wallet tab was not part of the prototype's nav bar.
- **Real payments** — card and USSD flows are simulated locally; a real payment gateway would need backend integration.
- **Font loading** — `google_fonts` fetches Plus Jakarta Sans from the internet on first run; bundle the font locally for offline production builds.
- **No internet + error states** — since there is no backend, network error screens were not required.

---

## Next steps for future development

1. **Add a real backend** — replace `AppState` methods with repository classes that call REST/gRPC APIs. Screen widgets need no changes.
2. **Authentication** — replace the sign-in bypass with JWT/session flow; add real biometric via `local_auth`.
3. **Payment integration** — wire the Fund Wallet screen to Paystack or Flutterwave SDK.
4. **Push notifications** — integrate Firebase Messaging; the `NotificationsScreen` is ready to accept dynamic data.
5. **Bundle fonts** — add Plus Jakarta Sans TTF files to `assets/fonts/` and update `pubspec.yaml` to avoid Google Fonts network dependency in production.
6. **Platform-specific tuning** — add splash screen assets via `flutter_native_splash` and a proper app icon via `flutter_launcher_icons`.
