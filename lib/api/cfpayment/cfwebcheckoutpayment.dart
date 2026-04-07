import '../../utils/cfexceptionconstants.dart';
import '../../utils/cfexceptions.dart';
import '../cfsession/cfsession.dart';
import '../cftheme/cftheme.dart';
import 'cfpayment.dart';

/// Builder for creating a [CFWebCheckoutPayment] object.
///
/// Example:
/// ```dart
/// final payment = CFWebCheckoutPaymentBuilder()
///   .setSession(session)
///   .setTheme(theme)
///   .build();
/// ```
class CFWebCheckoutPaymentBuilder {

  CFSession? _session;
  CFTheme _cfTheme = CFThemeBuilder().build();
  CFWebCheckoutPaymentBuilder();

  /// Sets the [CFSession] for this payment.
  CFWebCheckoutPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }


  /// Validates required fields and returns a [CFWebCheckoutPayment].
  ///
  /// Throws a [CFException] if session is not set.
  CFWebCheckoutPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFWebCheckoutPayment(this);
  }

  /// Sets an optional [CFTheme] to customize the web checkout appearance.
  CFWebCheckoutPaymentBuilder setTheme(CFTheme cfTheme) {
    _cfTheme = cfTheme;
    return this;
  }

  CFSession getSession() {
    return _session!;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }

}

/// Represents a complete web checkout payment object ready for submission.
///
/// Create instances using [CFWebCheckoutPaymentBuilder].
class CFWebCheckoutPayment extends CFPayment {

  late CFSession _session;
  CFTheme _cfTheme = CFThemeBuilder().build();

  // Constructor
  CFWebCheckoutPayment._();

  CFWebCheckoutPayment(CFWebCheckoutPaymentBuilder builder) {
    _session = builder.getSession();
    _cfTheme = builder.getTheme();
  }

  /// Returns the [CFSession] associated with this payment.
  CFSession getSession() {
    return _session;
  }

  /// Returns the [CFTheme] for this web checkout.
  CFTheme getTheme() {
    return _cfTheme;
  }

}
