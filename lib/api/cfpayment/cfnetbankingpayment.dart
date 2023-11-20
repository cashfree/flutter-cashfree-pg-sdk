import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFNetbankingPaymentBuilder {

  CFSession? _session;
  CFNetbanking? _cfNetbanking;

  CFNetbankingPaymentBuilder();

  CFNetbankingPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFNetbankingPaymentBuilder setNetbanking(CFNetbanking cfNetbanking) {
    _cfNetbanking = cfNetbanking;
    return this;
  }

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

class CFNetbankingPayment extends CFPayment {

  late CFSession _session;
  CFNetbanking? _cfNetbanking;

  // Constructor
  CFNetbankingPayment._();

  CFNetbankingPayment(CFNetbankingPaymentBuilder builder) {
    _session = builder.getSession();
    _cfNetbanking = builder.getNetbanking();
  }

  CFSession getSession() {
    return _session;
  }

  CFNetbanking getNetbanking() {
    return _cfNetbanking!;
  }
}