import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

/// Builder for creating a [CFSubscriptionSession] for subscription element payments.
///
/// Example:
/// ```dart
/// final session = CFSubscriptionSessionBuilder()
///   .setEnvironment(CFEnvironment.SANDBOX)
///   .setSubscriptionId("sub_123")
///   .setSubscriptionSessionId("sub_session_abc")
///   .build();
/// ```
class CFSubscriptionSessionBuilder {
  CFEnvironment? _environment;
  String? _subscriptionId;
  String? _subscriptionSessionID;

  CFSubscriptionSessionBuilder();

  /// Sets the environment ([CFEnvironment.SANDBOX] or [CFEnvironment.PRODUCTION]).
  CFSubscriptionSessionBuilder setEnvironment(CFEnvironment environment) {
    _environment = environment;
    return this;
  }

  CFEnvironment getEnvironment() {
    return _environment!;
  }

  /// Sets the subscription ID obtained from the Cashfree Subscriptions API.
  CFSubscriptionSessionBuilder setSubscriptionId(String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  /// Sets the subscription session ID for authenticating the subscription transaction.
  CFSubscriptionSessionBuilder setSubscriptionSessionId(String subscriptionSessionID) {
    _subscriptionSessionID = subscriptionSessionID;
    return this;
  }

  String getSubscriptionId() {
    return _subscriptionId!;
  }


  String getSubscriptionSessionId() {
    return _subscriptionSessionID!;
  }


  /// Validates all required fields and returns a [CFSubscriptionSession].
  ///
  /// Throws a [CFException] if environment, subscription ID, or subscription session ID is missing.
  CFSubscriptionSession build() {
    if (_environment == null) {
      throw CFException(CFExceptionConstants.ENVIRONMENT_NOT_PRESENT);
    }
    if (_subscriptionId == null || _subscriptionId!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_ID_NOT_PRESENT);
    }
    if(_subscriptionSessionID == null || _subscriptionSessionID!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_SESSION_ID_NOT_PRESENT);
    }
    return CFSubscriptionSession(this);
  }
}

/// Represents an authenticated session for subscription element payments.
///
/// Create instances using [CFSubscriptionSessionBuilder].
class CFSubscriptionSession {
  late CFEnvironment _environment;
  late String _subscriptionId;
  late String _subscriptionSessionID;

  CFSubscriptionSession._();

  CFSubscriptionSession(CFSubscriptionSessionBuilder sessionBuilder) {
    _environment = sessionBuilder.getEnvironment();
    _subscriptionSessionID = sessionBuilder.getSubscriptionSessionId();
    _subscriptionId = sessionBuilder.getSubscriptionId();
  }

  /// Returns the subscription ID associated with this session.
  String getSubscriptionId() {
    return _subscriptionId;
  }

  /// Returns the subscription session ID used to authenticate the transaction.
  String getSubscriptionSessionID() {
    return _subscriptionSessionID;
  }

  /// Returns the environment string (`"SANDBOX"` or `"PRODUCTION"`).
  String getEnvironment() {
    return _environment == CFEnvironment.SANDBOX ? CFEnvironment.SANDBOX.name : CFEnvironment.PRODUCTION.name;
  }
}
