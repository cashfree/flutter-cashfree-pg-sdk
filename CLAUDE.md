# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **Cashfree Payment Gateway Flutter plugin SDK** (`flutter_cashfree_pg_sdk`, v2.2.10+48). It wraps native Android (Java) and iOS (Swift) Cashfree SDKs via Flutter method channels, exposing payment APIs to Flutter apps.

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
- `doSubscriptionPayment` — Subscription
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

**Usage flow:**
1. Build a `CFSession` (environment, orderId, paymentSessionId)
2. Build the payment object (e.g., `CFDropCheckoutPayment`)
3. Call `CFPaymentGatewayService().setCallback(onVerify, onError)` to register callbacks
4. Call `CFPaymentGatewayService().doPayment(cfPayment)`
5. Verify order server-side in `onVerify(orderId)`

### Native SDK Versions
- Android: `com.cashfree.pg:api:2.2.9` (compileSdk 35, minSdk 19)
- iOS: `CashfreePG 2.2.7` (iOS 12.0+, Swift 5.0)

### Card Widget (special case)
`CFCardPayment` does not use a method channel. Instead, `CFCardWidget` is a Flutter widget rendered inline; card payment is completed directly from the widget's state via `CFCardWidgetState.completePayment()`. Card icon assets (Visa, Mastercard, etc.) are bundled in `assets/`.

### Web Support
`lib/flutter_cashfree_pg_sdk_web.dart` provides a stub/web implementation registered as `FlutterCashfreePgSdkWeb`.

## Version Update Checklist
When bumping the SDK version, update:
1. `pubspec.yaml` — `version`
2. `ios/flutter_cashfree_pg_sdk.podspec` — `s.version` and `s.dependency "CashfreePG"`
3. `android/build.gradle` — Cashfree dependency version
4. `ios/Classes/SwiftFlutterCashfreePgSdkPlugin.swift` — version constant if present
5. `CHANGELOG.md`