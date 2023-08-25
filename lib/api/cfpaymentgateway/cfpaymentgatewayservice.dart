
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupiintentcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import '../cfpayment/cfpayment.dart';

class CFPaymentGatewayService {
  static final CFPaymentGatewayService _singleton = CFPaymentGatewayService._internal();

  factory CFPaymentGatewayService() {
    return _singleton;
  }

  CFPaymentGatewayService._internal();

  static void Function(String)? verifyPayment;
  static void Function(CFErrorResponse, String)? onError;
  static void Function(List<Map<String, dynamic>>)? getUPIAppsCallback;

  setCallback(final void Function(String) vp, final void Function(CFErrorResponse, String) error, final void Function(List<Map<String, dynamic>>) appListCallback) {
    verifyPayment = vp;
    onError = error;
    getUPIAppsCallback = appListCallback;

    // Create Method channel here
    MethodChannel methodChannel = const MethodChannel('flutter_cashfree_pg_sdk');
    methodChannel.invokeMethod("response").then((value) {
      if(value != null) {
        final body = json.decode(value);
        var status = body["status"] as String;
        switch (status) {
          case "exception":
            var data = body["data"] as Map<String, dynamic>;
            _createErrorResponse(data["message"] as String, null, null, null);
            break;
          case "success":
            var data = body["data"] as Map<String, dynamic>;
            verifyPayment!(data["order_id"] as String);
            break;
          case "failed":
            var data = body["data"] as Map<String, dynamic>;
            var errorResponse = CFErrorResponse(
                data["status"] as String, data["message"] as String,
                data["code"] as String, data["type"] as String);
            onError!(errorResponse, data["order_id"] as String);
            break;
        }
      }
    });
  }

  // TODO: take id for flutter web
  getInstalledUPIApps() {
    MethodChannel methodChannel = const MethodChannel('flutter_cashfree_pg_sdk');
    methodChannel.invokeMethod("getInstalledUPIApps", null).then((value) {
      responseMethod(value);
    });
  }
  doPayment(CFPayment cfPayment) {
    if(verifyPayment == null || onError == null) {
      throw CFException(CFExceptionConstants.CALLBACK_NOT_SET);
    }

    Map<String, dynamic> data = <String, dynamic>{};

    if(cfPayment is CFDropCheckoutPayment) {
      CFDropCheckoutPayment dropCheckoutPayment = cfPayment;
      data = _convertToMap(dropCheckoutPayment);
    } else if(cfPayment is CFWebCheckoutPayment) {
      CFWebCheckoutPayment webCheckoutPayment = cfPayment;
      data = _convertToWebCheckoutMap(webCheckoutPayment);
    }else if(cfPayment is CFUPIIntentCheckoutPayment) {
      CFUPIIntentCheckoutPayment cfupiIntentCheckoutPayment = cfPayment;
      data = _convertToUPIIntentCheckoutMap(cfupiIntentCheckoutPayment);
    }

    // Create Method channel here
    MethodChannel methodChannel = const MethodChannel('flutter_cashfree_pg_sdk');
    if(cfPayment is CFDropCheckoutPayment) {
      methodChannel.invokeMethod("doPayment", data).then((value) {
        responseMethod(value);
      });
    } else if(cfPayment is CFWebCheckoutPayment) {
      methodChannel.invokeMethod("doWebPayment", data).then((value) {
        responseMethod(value);
      });
    } else if(cfPayment is CFUPIIntentCheckoutPayment) {
      methodChannel.invokeMethod("doUPIIntentPayment", data).then((value) {
        responseMethod(value);
      });
    }
  }

  void responseMethod(dynamic value) {
    if(value != null) {
      if (value is List) {
        List<Map<String, dynamic>> apps = [];
        for (var item in value) {
          // if (item is Map<Object, Object>) {
            Map<String, dynamic> convertedMap = {};
            item.forEach((key, value) {
              if (key is String) {
                convertedMap[key] = value;
              }
            });
            apps.add(convertedMap);
          // }
        }
        _sendUPIAppsCallback(apps);
        return;
      }
      final body = json.decode(value["data"]);

      var status = body["status"] as String;
      switch (status) {
        case "exception":
          var data = body["data"] as Map<String, dynamic>;
          _createErrorResponse(data["message"] as String, null, null, null);
          break;
        // case "getUPIAppsCallback":
        //   var data = body["data"] as List<Map<String, dynamic>>;
        //   _sendUPIAppsCallback(data);
        //   break;
        case "success":
          var data = body["data"] as Map<String, dynamic>;
          verifyPayment!(data["order_id"] as String);
          break;
        case "failed":
          var data = body["data"] as Map<String, dynamic>;
          var errorResponse = CFErrorResponse(
              data["status"] as String, data["message"] as String,
              data["code"] as String, data["type"] as String);
          onError!(errorResponse, data["order_id"] as String);
          break;
      }
    }
  }

  Map<String, dynamic> _convertToWebCheckoutMap(CFWebCheckoutPayment cfWebCheckoutPayment) {
    Map<String, dynamic> session = {
      "environment": cfWebCheckoutPayment.getSession().getEnvironment(),
      "order_id": cfWebCheckoutPayment.getSession().getOrderId(),
      "payment_session_id": cfWebCheckoutPayment.getSession()
          .getPaymentSessionId(),
    };

    Map<String, dynamic> data = {
      "session": session
    };
    return data;
  }
  Map<String, dynamic> _convertToUPIIntentCheckoutMap(CFUPIIntentCheckoutPayment cfupiIntentCheckoutPayment) {
    Map<String, dynamic> session = {
      "environment": cfupiIntentCheckoutPayment.getSession().getEnvironment(),
      "order_id": cfupiIntentCheckoutPayment.getSession().getOrderId(),
      "payment_session_id": cfupiIntentCheckoutPayment.getSession()
          .getPaymentSessionId(),
    };

    Map<String, dynamic> data = {
      "session": session,
      "package": cfupiIntentCheckoutPayment.package
    };
    return data;
  }

  Map<String, dynamic> _convertToMap(CFDropCheckoutPayment cfDropCheckoutPayment) {

    Map<String, dynamic> session = {
      "environment": cfDropCheckoutPayment.getSession().getEnvironment(),
      "order_id": cfDropCheckoutPayment.getSession().getOrderId(),
      "payment_session_id": cfDropCheckoutPayment.getSession().getPaymentSessionId(),
    };

    Map<String, dynamic> paymentComponents = {
      "components": cfDropCheckoutPayment.getPaymentComponent().getComponents()
    };

    Map<String, dynamic> theme = {
      "navigationBarBackgroundColor": cfDropCheckoutPayment.getTheme().getNavigationBarBackgroundColor(),
      "navigationBarTextColor": cfDropCheckoutPayment.getTheme().getNavigationBarTextColor(),
      "buttonBackgroundColor": cfDropCheckoutPayment.getTheme().getButtonBackgroundColor(),
      "buttonTextColor": cfDropCheckoutPayment.getTheme().getButtonTextColor(),
      "primaryTextColor": cfDropCheckoutPayment.getTheme().getPrimaryTextColor(),
      "secondaryTextColor": cfDropCheckoutPayment.getTheme().getSecondaryTextColor(),
      "primaryFont": cfDropCheckoutPayment.getTheme().getPrimaryFont(),
      "secondaryFont": cfDropCheckoutPayment.getTheme().getSecondaryFont()
    };

    Map<String, dynamic> data = {
      "session": session,
      "paymentComponents": paymentComponents,
      "theme": theme
    };
    return data;
  }

  _createErrorResponse(String? message, String? code, String? type, String? orderId) {
    var cfErrorResponse = CFErrorResponse("FAILED", message ?? "something went wrong", code ?? "invalid_request", type ?? "invalid_request");
    onError!(cfErrorResponse, orderId ?? "order_id_not_found");
  }
  _sendUPIAppsCallback(List<Map<String, dynamic>> appsList) {
    getUPIAppsCallback!(appsList);
  }
}