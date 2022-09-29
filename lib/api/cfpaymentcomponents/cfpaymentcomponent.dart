import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class CFPaymentComponentBuilder {
  List<CFPaymentModes> _components = [CFPaymentModes.CARD, CFPaymentModes.UPI, CFPaymentModes.NETBANKING, CFPaymentModes.WALLET, CFPaymentModes.PAYLATER, CFPaymentModes.EMI];

  CFPaymentComponentBuilder setComponents(List<CFPaymentModes> components) {
    if(components.isNotEmpty) {
      _components = components;
    }
    return this;
  }

  CFPaymentComponent build() {
    return CFPaymentComponent(this);
  }

  List<CFPaymentModes> getComponents() {
    return _components;
  }

}

class CFPaymentComponent {

  List<CFPaymentModes> _components = [CFPaymentModes.CARD, CFPaymentModes.UPI, CFPaymentModes.NETBANKING, CFPaymentModes.WALLET, CFPaymentModes.PAYLATER, CFPaymentModes.EMI];
  CFPaymentComponent._();

  CFPaymentComponent(CFPaymentComponentBuilder builder) {
    _components = builder.getComponents();
  }

  List<String> getComponents() {
    var i = 0;
    List<String> components = [];
    for(i=0; i<_components.length; i++) {
      components.add(_components[i].name.toLowerCase());
    }
    return components;
  }
}