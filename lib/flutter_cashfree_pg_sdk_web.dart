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
import 'dart:html' as html show window;
import 'dart:html';
import 'dart:js';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:js/js.dart';

import 'api/cferrorresponse/cferrorresponse.dart';


external Cashfree get cashfree;

@JS()
class Cashfree {
  external Cashfree(String paymentSessionId);
  external void drop(Element element, CFConfig cfConfig);
}

@JS()
@anonymous
class CFConfig {
  external List<String> get components;
  external String get orderToken;
  external String get pluginName;
  external Map<String, String> get style;
  external Function(dynamic) get onSuccess;
  external Function(dynamic) get onFailure;

  external factory CFConfig({List<String> components, String orderToken, String pluginName, Map<String, String> style, Function onSuccess, Function onFailure});
}

/// A web implementation of the FlutterCashfreePgSdkPlatform of the FlutterCashfreePgSdk plugin.
class FlutterCashfreePgSdkWeb {
  /// Constructs a FlutterCashfreePgSdkWeb
  FlutterCashfreePgSdkWeb();

  void Function(String)? _verifyPayment;
  void Function(CFErrorResponse, String)? _onError;

  DivElement? _outerDiv;
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
      message = transaction["txMsg"] as String ?? "";
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

    DivElement toast = DivElement();
    toast.text = message;
    toast.style.visibility = "visible";
    toast.style.minWidth = "200px";
    toast.style.position = "fixed";
    toast.style.left = "50%";
    toast.style.transform = "translate(-50%)";
    toast.style.top = "7.5%";
    toast.style.background = "red";
    toast.style.color = "white";
    toast.style.textAlign = "center";
    toast.style.verticalAlign = "middle";
    toast.style.lineHeight = "27px";
    toast.style.fontSize = "14px";
    toast.style.borderRadius = "5px";
    toast.style.padding = "8px";
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

  /// WEB
  void doPayment(dynamic arguments) async {
    var window = html.window;
    var document = window.document;
    
    print(window.navigator.userAgent);

    window.onHashChange.first.then((value) {
      _userCancelledTransaction();
    });

    var session = arguments["session"] as dynamic;
    var orderId = session["order_id"] as String;
    _order_id = orderId;


    /// Adding this outer div for opaque background
    DivElement outerDiv = DivElement();
    outerDiv.id = "cf-outer-div";
    outerDiv.style.position = "fixed";
    outerDiv.style.width = "100%";
    outerDiv.style.height = "100%";
    outerDiv.style.top = "0";
    outerDiv.style.left = "0";
    outerDiv.style.background = "#6b6c7b80";
    outerDiv.style.zIndex = "9999";

    /// This div element has the js sdk
    DivElement sdkDiv = DivElement();
    sdkDiv.id = "cf-flutter-placeholder";
    sdkDiv.style.position = "fixed";
    sdkDiv.style.left = "50%";
    sdkDiv.style.top = "50%";
    sdkDiv.style.width = "340px";
    // sdkDiv.style.minHeight = "350px";
    sdkDiv.style.height = "70%";
    sdkDiv.style.maxWidth = "100%";
    sdkDiv.style.transform = "translate(-50%, -50%)";
    sdkDiv.style.overflow = "auto";
    outerDiv.append(sdkDiv);

    /// This div element has the cross mark to close the sdk
    DivElement closeButton = DivElement();
    closeButton.text = "X";
    closeButton.style.position = "fixed";
    closeButton.style.right = "10px";
    closeButton.style.top = "10px";
    closeButton.style.fontSize = "24px";
    closeButton.style.color = "#ff0000";
    sdkDiv.append(closeButton);
    closeButton.onClick.listen((event) {
      _userCancelledTransaction();
    });

    document
        .querySelector("body")
        ?.children
        .add(outerDiv);

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

    var theme = arguments["theme"] as dynamic;
    String backgroundColor = theme["navigationBarBackgroundColor"] as String;
    String color = theme["navigationBarTextColor"] as String;
    String font = theme ["primaryFont"] as String;

    var style = {
      "backgroundColor": backgroundColor,
      "color": color,
      "fontFamily": font,
      "fontSize": "14px",
      "errorColor": "#ff0000",
      "theme": "light"
    };

    var script = document.createElement("SCRIPT") as ScriptElement;
    if(environment == "SANDBOX") {
      script.src =
      "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.sandbox.js ";
    } else {
      script.src =
      "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.prod.js";
    }
    script.onLoad.first.then((value) {
      var c = Cashfree(paymentSessionId);

      var element = document.getElementById("cf-flutter-placeholder") as Element;
      var os = allowInterop(onSuccess);
      var of = allowInterop(onFailure);

      var cfConfig = CFConfig(components: componentsToSend, pluginName: "jflt-d-2.0.3-3.3.10", onFailure: of, onSuccess: os, style: style);
      c.drop(element, cfConfig);
    });
    document.querySelector("body")?.children.add(script);
  }

}
