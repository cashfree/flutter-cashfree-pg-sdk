import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'package:flutter_cashfree_pg_sdk/utils/CFEnums.dart';

class CFSessionBuilder {

  CFEnvironment? _environment;
  String? _orderId;
  String? _orderToken;

  CFSessionBuilder();

  CFSessionBuilder setEnvironment(CFEnvironment environment) {
    _environment = environment;
    return this;
  }

  CFSessionBuilder setOrderId(String orderId) {
    _orderId = orderId;
    return this;
  }

  CFSessionBuilder setOrderToken(String orderToken) {
    _orderToken = orderToken;
    return this;
  }

  String getOrderId() {
    return _orderId!;
  }

  String getOrderToken() {
    return _orderToken!;
  }

  CFEnvironment getEnvironment() {
    return _environment!;
  }

  CFSession build() {
    if(_environment == null) {
      throw CFException(CFExceptionConstants.ENVIRONMENT_NOT_PRESENT);
    }
    if(_orderId == null || _orderId!.isEmpty) {
      throw CFException(CFExceptionConstants.ORDER_ID_NOT_PRESENT);
    }
    if(_orderToken == null || _orderToken!.isEmpty) {
      throw CFException(CFExceptionConstants.ORDER_TOKEN_NOT_PRESENT);
    }
    return CFSession(this);
  }

}

class CFSession {
  late CFEnvironment _environment;
  late String _orderId;
  late String _orderToken;

  CFSession._();

  CFSession(CFSessionBuilder sessionBuilder) {
    _environment = sessionBuilder.getEnvironment();
    _orderToken = sessionBuilder.getOrderToken();
    _orderId = sessionBuilder.getOrderId();
  }

  String getOrderId() {
    return _orderId;
  }

  String getOrderToken() {
    return _orderToken;
  }

  String getEnvironment() {
    return _environment == CFEnvironment.SANDBOX ? CFEnvironment.SANDBOX.name : CFEnvironment.PRODUCTION.name;
  }
}