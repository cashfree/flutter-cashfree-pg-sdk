import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class CFSubscriptionSessionBuilder {
  CFEnvironment? _environment;
  String? _subscriptionId;
  String? _subscriptionSessionID;

  CFSubscriptionSessionBuilder();

  CFSubscriptionSessionBuilder setEnvironment(CFEnvironment environment) {
    _environment = environment;
    return this;
  }

  CFEnvironment getEnvironment() {
    return _environment!;
  }

  CFSubscriptionSessionBuilder setSubscriptionId(String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  CFSubscriptionSessionBuilder setSubscriptionSessionId(String subscriptionSessionID) {
    _subscriptionSessionID = subscriptionSessionID;
    return this;
  }

  String getSubscriptionId() {
    return _subscriptionId!;
  }


  String getSubscriptionSessionId() {
    return _subscriptionSessionID!;
  }


  CFSubscriptionSession build() {
    if (_environment == null) {
      throw CFException(CFExceptionConstants.ENVIRONMENT_NOT_PRESENT);
    }
    if (_subscriptionId == null || _subscriptionId!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_ID_NOT_PRESENT);
    }
    if(_subscriptionSessionID == null || _subscriptionSessionID!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_SESSION_ID_NOT_PRESENT);
    }
    return CFSubscriptionSession(this);
  }
}

class CFSubscriptionSession {
  late CFEnvironment _environment;
  late String _subscriptionId;
  late String _subscriptionSessionID;

  CFSubscriptionSession._();

  CFSubscriptionSession(CFSubscriptionSessionBuilder sessionBuilder) {
    _environment = sessionBuilder.getEnvironment();
    _subscriptionSessionID = sessionBuilder.getSubscriptionSessionId();
    _subscriptionId = sessionBuilder.getSubscriptionId();
  }

  String getSubscriptionId() {
    return _subscriptionId;
  }

  String getSubscriptionSessionID() {
    return _subscriptionSessionID;
  }

  String getEnvironment() {
    return _environment == CFEnvironment.SANDBOX ? CFEnvironment.SANDBOX.name : CFEnvironment.PRODUCTION.name;
  }
}
