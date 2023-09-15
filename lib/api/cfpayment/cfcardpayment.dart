import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFCardPaymentBuilder {

  CFSession? _session;
  CFCard? _cfCard;
  bool _savePaymentMethod = false;

  CFCardPaymentBuilder();

  CFCardPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFCardPaymentBuilder setCard(CFCard cfCard) {
    _cfCard = cfCard;
    return this;
  }

  CFCardPaymentBuilder savePaymentMethod(bool flag) {
    _savePaymentMethod = flag;
    return this;
  }

  CFCardPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFCardPayment(this);
  }

  CFSession getSession() {
    return _session!;
  }

  CFCard getCard() {
    return _cfCard!;
  }

  bool getSavePaymentMethodFlag() {
    return _savePaymentMethod;
  }

}

class CFCardPayment extends CFPayment {

  late CFSession _session;
  CFCard? _cfCard;
  bool _savePaymentMethod = false;

  // Constructor
  CFCardPayment._();

  CFCardPayment(CFCardPaymentBuilder builder) {
    _session = builder.getSession();
    _cfCard = builder.getCard();
    _savePaymentMethod = builder.getSavePaymentMethodFlag();
  }

  CFSession getSession() {
    return _session;
  }

  CFCard getCard() {
    return _cfCard!;
  }

  bool getSavePaymentMethodFlag() {
    return _savePaymentMethod;
  }
}