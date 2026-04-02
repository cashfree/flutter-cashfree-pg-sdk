import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubscard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsubssession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFSubsCardPaymentBuilder {

  CFSubscriptionSession? _session;
  CFSubsCard? _cfCard;

  CFSubsCardPaymentBuilder();

  CFSubsCardPaymentBuilder setSession(CFSubscriptionSession session) {
    _session = session;
    return this;
  }

  CFSubsCardPaymentBuilder setCard(CFSubsCard cfCard) {
    _cfCard = cfCard;
    return this;
  }

  CFSubsCardPayment build() {
    if (_session == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_SESSION_NOT_PRESENT);
    }
    if (_cfCard == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_NOT_PRESENT);
    }
    return CFSubsCardPayment(this);
  }

  CFSubscriptionSession getSession() {
    return _session!;
  }

  CFSubsCard getCard() {
    return _cfCard!;
  }

}

class CFSubsCardPayment extends CFPayment {

  late CFSubscriptionSession _session;
  late CFSubsCard _cfCard;

  CFSubsCardPayment._();

  CFSubsCardPayment(CFSubsCardPaymentBuilder builder) {
    _session = builder.getSession();
    _cfCard = builder.getCard();
  }

  CFSubscriptionSession getSession() {
    return _session;
  }

  CFSubsCard getCard() {
    return _cfCard;
  }

}