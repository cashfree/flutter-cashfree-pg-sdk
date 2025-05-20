import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsubssession.dart';

import '../../utils/cfexceptionconstants.dart';
import '../../utils/cfexceptions.dart';
import '../cftheme/cftheme.dart';
import 'cfpayment.dart';

class CFSubscriptionPaymentBuilder {
  CFSubscriptionSession? _session;
  CFTheme _cfTheme = CFThemeBuilder().build();

  CFSubscriptionPaymentBuilder();

  CFSubscriptionPayment build() {
    if (_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFSubscriptionPayment(this);
  }

  CFSubscriptionPaymentBuilder setSession(CFSubscriptionSession session) {
    _session = session;
    return this;
  }

  CFSubscriptionPaymentBuilder setTheme(CFTheme cfTheme) {
    _cfTheme = cfTheme;
    return this;
  }

  CFSubscriptionSession getSession() {
    return _session!;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }
}

class CFSubscriptionPayment extends CFPayment {
  late CFSubscriptionSession _session;
  CFTheme _cfTheme = CFThemeBuilder().build();

  // Constructor
  CFSubscriptionPayment._();

  CFSubscriptionPayment(CFSubscriptionPaymentBuilder builder) {
    _session = builder.getSession();
    _cfTheme = builder.getTheme();
  }

  CFSubscriptionSession getSession() {
    return _session;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }
}
