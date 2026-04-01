# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **Cashfree Payment Gateway Flutter plugin SDK** (`flutter_cashfree_pg_sdk`, v2.3.2+49). It wraps native Android (Java) and iOS (Swift) Cashfree SDKs via Flutter method channels, exposing payment APIs to Flutter apps.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Analyze/lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/flutter_cashfree_pg_sdk_test.dart

# Run the example app (from example/)
cd example && flutter run

# Example app dependencies
cd example && flutter pub get

# iOS: install pods (from example/ios/)
cd example/ios && pod install

# Android: build (from android/)
cd android && ./gradlew build
```

## Architecture

### Plugin Structure
This is a Flutter federated plugin targeting Android, iOS, and Web:
- **Dart layer** (`lib/`): public API and method channel communication
- **Android layer** (`android/`): Java plugin (`FlutterCashfreePgSdkPlugin.java`)
- **iOS layer** (`ios/Classes/`): Swift plugin (`SwiftFlutterCashfreePgSdkPlugin.swift`)
- **Example app** (`example/`): full integration demo

### Method Channel
All platform communication goes through a single channel named `'flutter_cashfree_pg_sdk'`.

Methods invoked from Dart to native:
- `doPayment` — Drop checkout
- `doWebPayment` — Web checkout
- `doUPIPayment` — UPI collect
- `doUPIPaymentWithUI` — UPI intent with UI
- `doNetbankingPayment` — Netbanking
- `doCardPayment` — Direct card
- `doSubscriptionPayment` — Subscription drop checkout (web)
- `doSubsUPIPayment` — Subscription UPI (element)
- `doSubsNetbankingPayment` — Subscription Netbanking/eNACH (element)
- `doSubsCardPayment` — Subscription Card (element)
- `response` — Poll for pending response from native (called on `setCallback`)

All native responses are serialized JSON strings with this shape:
```json
{ "status": "success|failed|exception", "data": { ... } }
```

### Key Design Patterns

**Singleton** — `CFPaymentGatewayService` is a singleton; entry point for all payments.

**Builder pattern** — All payment and session objects are constructed via builders with validation:
- `CFSessionBuilder` → `CFSession`
- `CFSubscriptionSessionBuilder` → `CFSubscriptionSession`
- `CFDropCheckoutPaymentBuilder`, `CFWebCheckoutPaymentBuilder`, `CFCardPaymentBuilder`, `CFUPIPaymentBuilder`, `CFNetbankingPaymentBuilder`, `CFSubscriptionPaymentBuilder`
- `CFSubsUPIBuilder` → `CFSubsUPI`, `CFSubsUPIPaymentBuilder` → `CFSubsUPIPayment`
- `CFSubsNetbankingBuilder` → `CFSubsNetbanking`, `CFSubsNetbankingPaymentBuilder` → `CFSubsNetbankingPayment`
- `CFSubsCardBuilder` → `CFSubsCard`, `CFSubsCardPaymentBuilder` → `CFSubsCardPayment`

**Usage flow:**
1. Build a `CFSession` (environment, orderId, paymentSessionId)
2. Build the payment object (e.g., `CFDropCheckoutPayment`)
3. Call `CFPaymentGatewayService().setCallback(onVerify, onError)` to register callbacks
4. Call `CFPaymentGatewayService().doPayment(cfPayment)`
5. Verify order server-side in `onVerify(orderId)`

### Subscription Element Payment Flow
Subscription element payments (UPI, Netbanking, Card) use `CFSubscriptionSession` instead of `CFSession`:
1. Build a `CFSubscriptionSession` (environment, subscriptionId, subscriptionSessionId)
2. Build the element object (e.g., `CFSubsNetbanking`) with required fields — builder validates all fields on `build()`
3. Build the payment object (e.g., `CFSubsNetbankingPayment`) wrapping session + element
4. Call `CFPaymentGatewayService().setCallback(onVerify, onError)` — response uses `responseSubscriptionMethod`
5. Call `CFPaymentGatewayService().doPayment(cfPayment)`

#### Subscription Netbanking fields
`channel` is fixed to `"link"` (not exposed). Required fields: `auth_mode`, `account_holder_name`, `account_number`, `account_type`, `account_bank_code`.
Auth mode options: `"net_banking"`, `"aadhaar"`, `"debit_card"`.

#### Subscription Card fields
`channel` is fixed to `"link"` (not exposed). Required fields: `card_number`, `card_holder_name`, `card_expiry_mm`, `card_expiry_yy`, `card_cvv`.

#### Subscription UPI fields
`channel` is fixed to `INTENT`. Required fields: `upi_id`.

### Subscription Element — Android Native Classes
Located in `com.cashfree.pg.core.api.subscription.*`:
- UPI: `CFSubsUpi` / `CFSubsUpiPayment` (package: `subscription.upi`)
- Netbanking/eNACH: `CFSubsNetBanking` / `CFSubsNetBankingPayment` (package: `subscription.enach`)
- Card: `CFSubsCard` / `CFSubsCardPayment` (package: `subscription.card`)

All subscription element payments call `gatewayService.doSubscriptionPayment()` with `CFSDKFlavour.SUBSCRIPTION`.

### Subscription Element — iOS Native Classes
Located in `CashfreePGCoreSDK` (requires `CashfreePG 2.3.2+`):
- UPI: `CFUPISubs` / `CFUPISubsPayment` — built via `CFUPISubsBuilder().setUPIID(id)` / `CFUPIPaymentSubsBuilder()`
- Netbanking/eNACH: `CFNetBankingSubs` / `CFNetbankingSubsPayment` — built via `CFNetbankingSubsBuilder().setAuthMode().setBankAccountCode().setAccountHolderName().setAccountNumber().setAccountType()` / `CFNetbankingSubsPaymentBuilder()`
- Card: `CFCardSubs` / `CFCardSubsPayment` — built via `CFCardSubsBuilder().setCardNumber().setCardHolderName().setCardExpiryMonth().setCardExpiryYear().setCVV()` / `CFCardPaymentSubsBuilder()`

All subscription element payments call `cfPaymentGatewayService.doSubsPayment(_:viewController:)`.

**iOS vs Android difference:** On iOS, `upi_id` is a URI scheme (e.g. `phonepe://`, `tez://`). On Android it is the PSP app package name (e.g. `com.phonepe.app`). The example app detects platform and sets the appropriate default/hint.

### Native SDK Versions
- Android: `com.cashfree.pg:api:2.3.2` (compileSdk 35, minSdk 19)
- iOS: `CashfreePG 2.3.2` (iOS 12.0+, Swift 5.0)

### Card Widget (special case)
`CFCardPayment` does not use a method channel. Instead, `CFCardWidget` is a Flutter widget rendered inline; card payment is completed directly from the widget's state via `CFCardWidgetState.completePayment()`. Card icon assets (Visa, Mastercard, etc.) are bundled in `assets/`.

### Web Support
`lib/flutter_cashfree_pg_sdk_web.dart` provides a stub/web implementation registered as `FlutterCashfreePgSdkWeb`.

## File Map — Subscription Element Payments

| File | Purpose |
|------|---------|
| `lib/api/cfpayment/subs/cfsubsupi.dart` | `CFSubsUPIBuilder` + `CFSubsUPI` model |
| `lib/api/cfpayment/subs/cfsubsupipayment.dart` | `CFSubsUPIPaymentBuilder` + `CFSubsUPIPayment` |
| `lib/api/cfpayment/subs/cfsubsnetbanking.dart` | `CFSubsNetbankingBuilder` + `CFSubsNetbanking` model |
| `lib/api/cfpayment/subs/cfsubsnetbankingpayment.dart` | `CFSubsNetbankingPaymentBuilder` + `CFSubsNetbankingPayment` |
| `lib/api/cfpayment/subs/cfsubscard.dart` | `CFSubsCardBuilder` + `CFSubsCard` model |
| `lib/api/cfpayment/subs/cfsubscardpayment.dart` | `CFSubsCardPaymentBuilder` + `CFSubsCardPayment` |

## Version Update Checklist
When bumping the SDK version, update:
1. `pubspec.yaml` — `version`
2. `ios/flutter_cashfree_pg_sdk.podspec` — `s.version` and `s.dependency "CashfreePG"`
3. `android/build.gradle` — Cashfree dependency version
4. `ios/Classes/SwiftFlutterCashfreePgSdkPlugin.swift` — `versionNumber` constant
5. `CHANGELOG.md`
6. `CLAUDE.md` — version in Overview and Native SDK Versions