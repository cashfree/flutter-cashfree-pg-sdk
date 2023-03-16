import '../../utils/cfexceptionconstants.dart';
import '../../utils/cfexceptions.dart';
import '../cfsession/cfsession.dart';
import 'cfpayment.dart';

class CFWebCheckoutPaymentBuilder {

  CFSession? _session;

  CFWebCheckoutPaymentBuilder();

  CFWebCheckoutPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }


  CFWebCheckoutPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFWebCheckoutPayment(this);
  }

  CFSession getSession() {
    return _session!;
  }

}

class CFWebCheckoutPayment extends CFPayment {

  late CFSession _session;

  // Constructor
  CFWebCheckoutPayment._();

  CFWebCheckoutPayment(CFWebCheckoutPaymentBuilder builder) {
    _session = builder.getSession();
  }

  CFSession getSession() {
    return _session;
  }

}