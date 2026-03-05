// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

/**
    Predefining a structure to send back response in json string
    onSuccess
    {
    "status": "success",
    "data": {
    "order_id": ""
    }
    }

    onFailure
    {
    "status": "failed",
    "data": {
    "order_id":"",
    "message":"",
    "code":"",
    "type":"",
    "":""
    }
    }

    onException
    {
    "status": "exception",
    "data": {
    "message": ""
    }
    }
 */

@JS('CFFlutter')
library CFFlutter;

import 'dart:async';
import 'dart:convert';
import 'package:web/web.dart' as web;

import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'dart:js_interop';
import 'dart:developer' as developer;

import 'api/cferrorresponse/cferrorresponse.dart';

@JS()
@staticInterop
class Cashfree {
  external factory Cashfree(String paymentSessionId);
}

extension CashfreeExt on Cashfree {
  external void drop(web.Element element, CFConfig cfConfig);
  external void redirect();
}

@JS()
@staticInterop
@anonymous
class CFConfig {
  external factory CFConfig({
    JSArray<JSString> components,
    String orderToken,
    String pluginName,
    Style style,
    JSFunction onSuccess,
    JSFunction onFailure,
  });
}

@JS()
@staticInterop
@anonymous
class Style {
  external factory Style({
    String backgroundColor,
    String color,
    String fontFamily,
    String fontSize,
    String errorColor,
    String theme,
  });
}

/// A web implementation of the FlutterCashfreePgSdkPlatform of the FlutterCashfreePgSdk plugin.
class FlutterCashfreePgSdkWeb {
  /// Constructs a FlutterCashfreePgSdkWeb
  FlutterCashfreePgSdkWeb();

  void Function(String)? _verifyPayment;
  void Function(CFErrorResponse, String)? _onError;

  web.HTMLDivElement? _outerDiv;
  String? _order_id;

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'flutter_cashfree_pg_sdk',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = FlutterCashfreePgSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'doPayment':
        var arguments = call.arguments as dynamic;
        doPayment(arguments);
        break;
      case 'doWebPayment':
        var arguments = call.arguments as dynamic;
        doWebPayment(arguments);
        break;
      case "response":
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_cashfree_pg_sdk for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void onSuccess(String data) {
    var jsonObject = json.decode(data) as Map<String, dynamic>;
    var order = jsonObject["order"];
    var orderId = order["orderId"] as String;
    if(_verifyPayment != null) {
      _verifyPayment!(orderId);
      _outerDiv?.remove();
    }
  }

  void onFailure(String data) {
    var jsonObject = json.decode(data) as Map<String, dynamic>;
    var order = jsonObject["order"];
    var orderId = order["orderId"] as dynamic ?? "";
    var message = order["errorText"] as String? ?? "";
    var transaction = jsonObject["transaction"] as dynamic;
    if(transaction != null) {
      message = transaction["txMsg"] as String;
      if(_onError != null) {
        var errorResponse = CFErrorResponse("FAILED", message, "invalid_request", "invalid request");
        _onError!(errorResponse, orderId);
        _outerDiv?.remove();
      }
    } else {
      if((message.toLowerCase() == "order is no longer active") || (message.toLowerCase() == "token is not present")) {
        if(_onError != null) {
          var errorResponse = CFErrorResponse("FAILED", message, "invalid_request", "invalid request");
          _onError!(errorResponse, orderId.toString());
          _outerDiv?.remove();
        }
      } else {
        _showToast(message);
      }
    }
  }

  void _showToast(String message) {
    final toast = web.document.createElement('div') as web.HTMLDivElement;
    toast.text = message;
    toast.style
      ..visibility = "visible"
      ..minWidth = "200px"
      ..position = "fixed"
      ..left = "50%"
      ..transform = "translate(-50%)"
      ..top = "7.5%"
      ..background = "red"
      ..color = "white"
      ..textAlign = "center"
      ..verticalAlign = "middle"
      ..lineHeight = "27px"
      ..fontSize = "14px"
      ..borderRadius = "5px"
      ..padding = "8px";
    _outerDiv?.append(toast);

    Timer.periodic(const Duration(seconds: 5), (timer) {
      toast.remove();
      timer.cancel();
    });
  }

  void _userCancelledTransaction() {
    if(_onError != null) {
      var errorResponse = CFErrorResponse(
          "FAILED", "Transaction cancelled by user", "invalid_request",
          "invalid request");
      _onError!(errorResponse, _order_id ?? "order_id_not_found");
      _outerDiv?.remove();
    }
  }

  /// WEB REDIRECTION
  void doWebPayment(dynamic arguments) {
    final window = web.window;
    final document = window.document;

    var session = arguments["session"] as dynamic;

    String environment = session["environment"] as String;
    String paymentSessionId = session["payment_session_id"] as String;

    var script = document.createElement("script") as web.HTMLScriptElement;
    if (environment == "SANDBOX") {
      script.src =
          "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.sandbox.js ";
    } else {
      script.src = "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.prod.js";
    }
    script.onLoad.first.then((value) {
      var c = Cashfree(paymentSessionId);
      c.redirect();
    });
    document.querySelector("body")?.append(script);
  }

  /// WEB
  void doPayment(dynamic arguments) async {
    final window = web.window;
    final document = window.document;

    window.addEventListener(
        'hashchange',
        ((web.Event _) {
          _userCancelledTransaction();
        }).toJS);


    var session = arguments["session"] as dynamic;
    var orderId = session["order_id"] as String;
    _order_id = orderId;

    /// Adding this outer div for opaque background
    final outerDiv = document.createElement('div') as web.HTMLDivElement;
    outerDiv.id = "cf-outer-div";
    outerDiv.style
      ..position = "fixed"
      ..width = "100%"
      ..height = "100%"
      ..top = "0"
      ..left = "0"
      ..background = "#6b6c7b80"
      ..zIndex = "9999";

    /// This div element has the js sdk
    final sdkDiv = document.createElement('div') as web.HTMLDivElement;
    sdkDiv.id = "cf-flutter-placeholder";
    sdkDiv.style
      ..position = "fixed"
      ..left = "50%"
      ..top = "50%"
      ..width = "400px"
      ..height = "100%"
      ..maxWidth = "100%"
      ..transform = "translate(-50%, -50%)"
      ..overflow = "auto";
    outerDiv.append(sdkDiv);

    /// This div element has the cross mark to close the sdk
    final closeButton = document.createElement('div') as web.HTMLDivElement;
    closeButton.text = "X";
    closeButton.style.position = "fixed";
    closeButton.style.right = "10px";
    closeButton.style.top = "10px";
    closeButton.style.fontSize = "24px";
    closeButton.style.color = "#ff0000";
    sdkDiv.append(closeButton);
    closeButton.addEventListener(
        'click',
        ((web.Event _) {
          developer.log('closeButton Clicked');
          _userCancelledTransaction();
        }).toJS);

    document.querySelector("body")?.append(outerDiv);

    /// Taking an instance of outer div to close it later
    _outerDiv = outerDiv;

    _onError = CFPaymentGatewayService.onError;
    _verifyPayment = CFPaymentGatewayService.verifyPayment;

    String environment = session["environment"] as String;
    String paymentSessionId = session["payment_session_id"] as String;

    var paymentComponents = arguments["paymentComponents"] as dynamic;
    var components = paymentComponents["components"] as List<dynamic>;
    List<String> componentsToSend = [];
    componentsToSend.add("order-details");
    for(int i = 0; i < components.length; i++) {
      if(components[i] == "wallet") {
        componentsToSend.add("app");
      } else if(components[i] == "emi") {
        componentsToSend.add("creditcardemi");
        componentsToSend.add("cardlessemi");
      } else {
        componentsToSend.add(components[i].toString());
      }
    }

    final theme = arguments['theme'] as Map<String, dynamic>;
    final style = Style(
      backgroundColor: (theme['navigationBarBackgroundColor'] as String?) ?? '',
      color: (theme['navigationBarTextColor'] as String?) ?? '',
      fontFamily: (theme['primaryFont'] as String?) ?? '',
      fontSize: '14px',
      errorColor: '#ff0000',
      theme: 'light',
    );

    var script = document.createElement("script") as web.HTMLScriptElement;
    if (environment == "SANDBOX") {
      script.src =
          "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.sandbox.js ";
    } else {
      script.src = "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.prod.js";
    }
    script.onLoad.first.then((value) {
      var c = Cashfree(paymentSessionId);

      var element =
          document.getElementById("cf-flutter-placeholder") as web.Element;

      // Pass Dart callbacks to JS using `.toJS`.
      final os = ((String data) => onSuccess(data)).toJS;
      final of = ((String data) => onFailure(data)).toJS;

      final jsComponents = componentsToSend.map((s) => s.toJS).toList().toJS;



      var cfConfig = CFConfig(
          components: jsComponents,
          pluginName: "jflt-d-2.0.10-3.3.10",
          onFailure: of,
          onSuccess: os,
          style: style);
      c.drop(element, cfConfig);
    });
    document.querySelector("body")?.append(script);
  }
}
