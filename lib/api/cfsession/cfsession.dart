import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

/// Builder for creating a [CFSession] with the required payment session parameters.
///
/// Example:
/// ```dart
/// final session = CFSessionBuilder()
///   .setEnvironment(CFEnvironment.SANDBOX)
///   .setOrderId("order_123")
///   .setPaymentSessionId("session_abc")
///   .build();
/// ```
class CFSessionBuilder {
  CFEnvironment? _environment;
  String? _orderId;
  String? _paymentSessionId;
  String? _orderToken;

  CFSessionBuilder();

  /// Sets the environment ([CFEnvironment.SANDBOX] or [CFEnvironment.PRODUCTION]).
  CFSessionBuilder setEnvironment(CFEnvironment environment) {
    _environment = environment;
    return this;
  }

  /// Sets the order ID for the payment session.
  CFSessionBuilder setOrderId(String orderId) {
    _orderId = orderId;
    return this;
  }

  @Deprecated(
      "order_token will no longer be used in the integration steps. Please switch to payment_session_id using setPaymentSessionId() method")
  CFSessionBuilder setOrderToken(String orderToken) {
    _orderToken = orderToken;
    return this;
  }

  /// Sets the payment session ID obtained from the Cashfree Orders API.
  CFSessionBuilder setPaymentSessionId(String paymentSessionId) {
    _paymentSessionId = paymentSessionId;
    return this;
  }

  String getOrderId() {
    return _orderId!;
  }

  String getOrderToken() {
    return _orderToken ?? "";
  }

  String getPaymentSessionId() {
    return _paymentSessionId!;
  }

  CFEnvironment getEnvironment() {
    return _environment!;
  }

  /// Validates all required fields and returns a [CFSession].
  ///
  /// Throws a [CFException] if environment, order ID, or payment session ID is missing.
  CFSession build() {
    if (_environment == null) {
      throw CFException(CFExceptionConstants.ENVIRONMENT_NOT_PRESENT);
    }
    if (_orderId == null || _orderId!.isEmpty) {
      throw CFException(CFExceptionConstants.ORDER_ID_NOT_PRESENT);
    }
    if(_paymentSessionId == null || _paymentSessionId!.isEmpty) {
      throw CFException(CFExceptionConstants.PAYMENT_SESSION_ID_NOT_PRESENT);
    }
    return CFSession(this);
  }
}

/// Represents an authenticated payment session for the Cashfree payment gateway.
///
/// Create instances using [CFSessionBuilder].
class CFSession {
  late CFEnvironment _environment;
  late String _orderId;
  late String _orderToken;
  late String _paymentSessionId;

  CFSession._();

  CFSession(CFSessionBuilder sessionBuilder) {
    _environment = sessionBuilder.getEnvironment();
    _paymentSessionId = sessionBuilder.getPaymentSessionId();
    _orderId = sessionBuilder.getOrderId();
  }

  /// Returns the order ID associated with this session.
  String getOrderId() {
    return _orderId;
  }

  String getOrderToken() {
    return _orderToken;
  }

  /// Returns the payment session ID used to authenticate the transaction.
  String getPaymentSessionId() {
    return _paymentSessionId;
  }

  /// Returns the environment string (`"SANDBOX"` or `"PRODUCTION"`).
  String getEnvironment() {
    return _environment == CFEnvironment.SANDBOX ? CFEnvironment.SANDBOX.name : CFEnvironment.PRODUCTION.name;
  }

  /// Returns the [CFEnvironment] enum value for this session.
  CFEnvironment getEnvironmentEnum() {
    return _environment;
  }
}
