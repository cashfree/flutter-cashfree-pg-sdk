import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import '../cfpaymentcomponents/cfpaymentcomponent.dart';
import '../cftheme/cftheme.dart';

class CFDropCheckoutPaymentBuilder {

  CFSession? _session;
  CFTheme _cfTheme = CFThemeBuilder().build();
  CFPaymentComponent _paymentComponent = CFPaymentComponentBuilder().build();

  CFDropCheckoutPaymentBuilder();

  CFDropCheckoutPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFDropCheckoutPaymentBuilder setTheme(CFTheme cfTheme) {
    _cfTheme = cfTheme;
    return this;
  }

  CFDropCheckoutPaymentBuilder setPaymentComponent(CFPaymentComponent cfPaymentComponent) {
    _paymentComponent = cfPaymentComponent;
    return this;
  }

  CFDropCheckoutPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFDropCheckoutPayment(this);
  }

  CFSession getSession() {
    return _session!;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }

  CFPaymentComponent getPaymentComponent() {
    return _paymentComponent;
  }

}

class CFDropCheckoutPayment extends CFPayment {

  late CFSession _session;
  CFTheme _cfTheme = CFThemeBuilder().build();
  CFPaymentComponent _paymentComponent = CFPaymentComponentBuilder().build();

  // Constructor
  CFDropCheckoutPayment._();

  CFDropCheckoutPayment(CFDropCheckoutPaymentBuilder builder) {
    _session = builder.getSession();
    _cfTheme = builder.getTheme();
    _paymentComponent = builder.getPaymentComponent();
  }

  CFSession getSession() {
    return _session;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }

  CFPaymentComponent getPaymentComponent() {
    return _paymentComponent;
  }

}