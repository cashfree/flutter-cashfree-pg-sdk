import '../../utils/cfexceptionconstants.dart';
import '../../utils/cfexceptions.dart';
import '../cfsession/cfsession.dart';
import 'cfpayment.dart';

class CFUPIIntentCheckoutPaymentBuilder {

  CFSession? _session;
  CFSession? get session => _session;

  String? _package;
  String? get package => _package;

  CFUPIIntentCheckoutPaymentBuilder();

  CFUPIIntentCheckoutPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFUPIIntentCheckoutPaymentBuilder setPackage(String package) {
    _package = package;
    return this;
  }


  CFUPIIntentCheckoutPayment build() {
    if(_session == null) {
      throw CFException(CFExceptionConstants.SESSION_NOT_PRESENT);
    }
    return CFUPIIntentCheckoutPayment(this);
  }


}

class CFUPIIntentCheckoutPayment extends CFPayment {

  late CFSession _session;
  late String? _package;

  String? get package => _package;

  // Constructor
  CFUPIIntentCheckoutPayment._();

  CFUPIIntentCheckoutPayment(CFUPIIntentCheckoutPaymentBuilder builder) {
    _session = builder.session!;
    _package = builder.package;
  }

  CFSession getSession() {
    return _session;
  }

}