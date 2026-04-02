import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsubssession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFSubsNetbankingPaymentBuilder {

  CFSubscriptionSession? _session;
  CFSubsNetbanking? _cfNetbanking;

  CFSubsNetbankingPaymentBuilder();

  CFSubsNetbankingPaymentBuilder setSession(CFSubscriptionSession session) {
    _session = session;
    return this;
  }

  CFSubsNetbankingPaymentBuilder setNetbanking(CFSubsNetbanking cfNetbanking) {
    _cfNetbanking = cfNetbanking;
    return this;
  }

  CFSubsNetbankingPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_SESSION_NOT_PRESENT);
    }
    if(_cfNetbanking == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_NOT_PRESENT);
    }
    return CFSubsNetbankingPayment(this);
  }

  CFSubscriptionSession getSession() {
    return _session!;
  }

  CFSubsNetbanking getNetbanking() {
    return _cfNetbanking!;
  }

}

class CFSubsNetbankingPayment extends CFPayment {

  late CFSubscriptionSession _session;
  late CFSubsNetbanking _cfNetbanking;

  CFSubsNetbankingPayment._();

  CFSubsNetbankingPayment(CFSubsNetbankingPaymentBuilder builder) {
    _session = builder.getSession();
    _cfNetbanking = builder.getNetbanking();
  }

  CFSubscriptionSession getSession() {
    return _session;
  }

  CFSubsNetbanking getNetbanking() {
    return _cfNetbanking;
  }
}