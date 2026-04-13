import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

/// Builder for creating a [CFUPIPayment] object.
///
/// Example:
/// ```dart
/// final payment = CFUPIPaymentBuilder()
///   .setSession(session)
///   .setUPI(upi)
///   .build();
/// ```
class CFUPIPaymentBuilder {

  CFSession? _session;
  CFUPI? _cfupi;

  CFUPIPaymentBuilder();

  /// Sets the [CFSession] for this payment.
  CFUPIPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  /// Sets the [CFUPI] payment method details.
  CFUPIPaymentBuilder setUPI(CFUPI cfupi) {
    _cfupi = cfupi;
    return this;
  }

  /// Validates required fields and returns a [CFUPIPayment].
  ///
  /// Throws a [CFException] if session is not set.
  CFUPIPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFUPIPayment(this);
  }

  CFSession getSession() {
    return _session!;
  }

  CFUPI getUPI() {
    return _cfupi!;
  }

}

/// Represents a complete UPI payment object ready for submission.
///
/// Create instances using [CFUPIPaymentBuilder].
class CFUPIPayment extends CFPayment {

  late CFSession _session;
  CFUPI? _cfupi;

  // Constructor
  CFUPIPayment._();

  CFUPIPayment(CFUPIPaymentBuilder builder) {
    _session = builder.getSession();
    _cfupi = builder.getUPI();
  }

  /// Returns the [CFSession] associated with this payment.
  CFSession getSession() {
    return _session;
  }

  /// Returns the [CFUPI] payment method details.
  CFUPI getUPI() {
    return _cfupi!;
  }
}
