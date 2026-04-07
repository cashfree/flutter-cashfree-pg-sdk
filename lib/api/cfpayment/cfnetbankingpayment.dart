import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

/// Builder for creating a [CFNetbankingPayment] object.
///
/// Example:
/// ```dart
/// final payment = CFNetbankingPaymentBuilder()
///   .setSession(session)
///   .setNetbanking(netbanking)
///   .build();
/// ```
class CFNetbankingPaymentBuilder {

  CFSession? _session;
  CFNetbanking? _cfNetbanking;

  CFNetbankingPaymentBuilder();

  /// Sets the [CFSession] for this payment.
  CFNetbankingPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  /// Sets the [CFNetbanking] payment method details.
  CFNetbankingPaymentBuilder setNetbanking(CFNetbanking cfNetbanking) {
    _cfNetbanking = cfNetbanking;
    return this;
  }

  /// Validates required fields and returns a [CFNetbankingPayment].
  ///
  /// Throws a [CFException] if session is not set.
  CFNetbankingPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFNetbankingPayment(this);
  }

  CFSession getSession() {
    return _session!;
  }

  CFNetbanking getNetbanking() {
    return _cfNetbanking!;
  }

}

/// Represents a complete netbanking payment object ready for submission.
///
/// Create instances using [CFNetbankingPaymentBuilder].
class CFNetbankingPayment extends CFPayment {

  late CFSession _session;
  CFNetbanking? _cfNetbanking;

  // Constructor
  CFNetbankingPayment._();

  CFNetbankingPayment(CFNetbankingPaymentBuilder builder) {
    _session = builder.getSession();
    _cfNetbanking = builder.getNetbanking();
  }

  /// Returns the [CFSession] associated with this payment.
  CFSession getSession() {
    return _session;
  }

  /// Returns the [CFNetbanking] payment method details.
  CFNetbanking getNetbanking() {
    return _cfNetbanking!;
  }
}
