import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsubssession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFSubsUPIPaymentBuilder {

  CFSubscriptionSession? _session;
  CFSubsUPI? _cfupi;

  CFSubsUPIPaymentBuilder();

  CFSubsUPIPaymentBuilder setSession(CFSubscriptionSession session) {
    _session = session;
    return this;
  }

  CFSubsUPIPaymentBuilder setUPI(CFSubsUPI cfupi) {
    _cfupi = cfupi;
    return this;
  }

  CFSubsUPIPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_SESSION_NOT_PRESENT);
    }
    if(_cfupi == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_UPI_NOT_PRESENT);
    }
    return CFSubsUPIPayment(this);
  }

  CFSubscriptionSession getSession() {
    return _session!;
  }

  CFSubsUPI getUPI() {
    return _cfupi!;
  }

}

class CFSubsUPIPayment extends CFPayment {

  late CFSubscriptionSession _session;
  late CFSubsUPI _cfupi;

  CFSubsUPIPayment._();

  CFSubsUPIPayment(CFSubsUPIPaymentBuilder builder) {
    _session = builder.getSession();
    _cfupi = builder.getUPI();
  }

  CFSubscriptionSession getSession() {
    return _session;
  }

  CFSubsUPI getUPI() {
    return _cfupi;
  }
}