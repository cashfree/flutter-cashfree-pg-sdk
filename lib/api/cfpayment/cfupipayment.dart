import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFUPIPaymentBuilder {

  CFSession? _session;
  CFUPI? _cfupi;

  CFUPIPaymentBuilder();

  CFUPIPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFUPIPaymentBuilder setUPI(CFUPI cfupi) {
    _cfupi = cfupi;
    return this;
  }

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

class CFUPIPayment extends CFPayment {

  late CFSession _session;
  CFUPI? _cfupi;

  // Constructor
  CFUPIPayment._();

  CFUPIPayment(CFUPIPaymentBuilder builder) {
    _session = builder.getSession();
    _cfupi = builder.getUPI();
  }

  CFSession getSession() {
    return _session;
  }

  CFUPI getUPI() {
    return _cfupi!;
  }
}