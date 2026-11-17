// Web implementation of flutter_cashfree_pg_sdk.
//
// Built on `package:web` + `dart:js_interop` so it compiles with both dart2js
// and dart2wasm (`flutter build web --wasm`). Do not reintroduce `dart:html`,
// `dart:js` or `package:js`: they are unsupported under Wasm.

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

// Every top-level JS binding in this library resolves under the global
// `CFFlutter` object exposed by the Cashfree JS SDK (window.CFFlutter.Cashfree).
@JS('CFFlutter')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'api/cferrorresponse/cferrorresponse.dart';
import 'src/cf_sdk_version.dart';

/// `window.CFFlutter.Cashfree` from the Cashfree JS SDK.
@JS('Cashfree')
extension type _Cashfree._(JSObject _) implements JSObject {
  external _Cashfree(String paymentSessionId);
  external void drop(web.Element element, _CFConfig config);
  external void redirect();
}

/// Config object literal passed to `Cashfree.drop`.
extension type _CFConfig._(JSObject _) implements JSObject {
  external factory _CFConfig({
    JSArray<JSString> components,
    String pluginName,
    JSFunction onSuccess,
    JSFunction onFailure,
  });
}

/// A web implementation of the FlutterCashfreePgSdkPlatform of the FlutterCashfreePgSdk plugin.
class FlutterCashfreePgSdkWeb {
  /// Constructs a FlutterCashfreePgSdkWeb
  FlutterCashfreePgSdkWeb();

  // Analytics tag read by Cashfree: j(s)flt-d(rop)-<plugin version>-3.3.10.
  // Only the version segment is dynamic; the rest is kept as-is because the
  // backend's parsing of it is not documented here.
  static const String _pluginName = "jflt-d-$cfSdkVersion-3.3.10";
  static const String _outerDivId = "cf-outer-div";
  static const String _placeholderId = "cf-flutter-placeholder";
  static const String _closeButtonId = "cf-close-button";

  /// Lets tests point the plugin at a stub SDK instead of the Cashfree CDN.
  @visibleForTesting
  static String Function(String environment)? sdkScriptUrlOverride;

  /// URL of the Cashfree JS SDK for [environment] ("SANDBOX" or "PRODUCTION").
  static String sdkScriptUrl(String environment) {
    final override = sdkScriptUrlOverride;
    if (override != null) return override(environment);
    return environment == "SANDBOX"
        ? "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.sandbox.js"
        : "https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.prod.js";
  }

  void Function(String)? _verifyPayment;
  void Function(CFErrorResponse, String)? _onError;

  web.HTMLDivElement? _outerDiv;
  String? _orderId;
  JSFunction? _hashChangeListener;

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
        doPayment(call.arguments as Map);
        break;
      case 'doWebPayment':
        doWebPayment(call.arguments as Map);
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
    final jsonObject = json.decode(data) as Map<String, dynamic>;
    final order = jsonObject["order"] as Map<String, dynamic>;
    final orderId = order["orderId"] as String;
    if (_verifyPayment != null) {
      _finish();
      _verifyPayment!(orderId);
    }
  }

  void onFailure(String data) {
    final jsonObject = json.decode(data) as Map<String, dynamic>;
    final order = jsonObject["order"] as Map<String, dynamic>? ?? const {};
    final orderId = (order["orderId"] ?? "").toString();
    var message = order["errorText"] as String? ?? "";
    final transaction = jsonObject["transaction"] as Map<String, dynamic>?;
    if (transaction != null) {
      message = transaction["txMsg"] as String? ?? message;
      _reportError(message, orderId);
    } else if (message.toLowerCase() == "order is no longer active" ||
        message.toLowerCase() == "token is not present") {
      _reportError(message, orderId);
    } else {
      _showToast(message);
    }
  }

  void _reportError(String message, String orderId) {
    if (_onError == null) return;
    _finish();
    _onError!(CFErrorResponse("FAILED", message, "invalid_request", "invalid request"), orderId);
  }

  /// Tears down the overlay and the hashchange listener once a payment ends,
  /// so a later route change can't fire a spurious "cancelled" error.
  void _finish() {
    final listener = _hashChangeListener;
    if (listener != null) {
      web.window.removeEventListener('hashchange', listener);
      _hashChangeListener = null;
    }
    _outerDiv?.remove();
    _outerDiv = null;
  }

  void _showToast(String message) {
    final toast = web.HTMLDivElement()..textContent = message;
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

    Timer(const Duration(seconds: 5), () => toast.remove());
  }

  void _userCancelledTransaction() {
    _reportError("Transaction cancelled by user", _orderId ?? "order_id_not_found");
  }

  /// Injects the Cashfree JS SDK and runs [onLoaded] once it is available.
  void _loadSdk(String environment, void Function() onLoaded) {
    final script = web.HTMLScriptElement()..src = sdkScriptUrl(environment);
    script.addEventListener('load', ((web.Event _) => onLoaded()).toJS);
    web.document.body?.append(script);
  }

  /// WEB REDIRECTION
  void doWebPayment(Map arguments) {
    final session = arguments["session"] as Map;
    final environment = session["environment"] as String;
    final paymentSessionId = session["payment_session_id"] as String;

    _loadSdk(environment, () => _Cashfree(paymentSessionId).redirect());
  }

  /// WEB
  void doPayment(Map arguments) {
    _finish();

    final session = arguments["session"] as Map;
    _orderId = session["order_id"] as String;
    _onError = CFPaymentGatewayService.onError;
    _verifyPayment = CFPaymentGatewayService.verifyPayment;

    final listener = ((web.Event _) => _userCancelledTransaction()).toJS;
    _hashChangeListener = listener;
    web.window.addEventListener('hashchange', listener);

    /// Adding this outer div for opaque background
    final outerDiv = web.HTMLDivElement()..id = _outerDivId;
    outerDiv.style
      ..position = "fixed"
      ..width = "100%"
      ..height = "100%"
      ..top = "0"
      ..left = "0"
      ..background = "#6b6c7b80"
      ..zIndex = "9999";

    /// This div element has the js sdk
    final sdkDiv = web.HTMLDivElement()..id = _placeholderId;
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
    final closeButton = web.HTMLDivElement()
      ..id = _closeButtonId
      ..textContent = "X";
    closeButton.style
      ..position = "fixed"
      ..right = "10px"
      ..top = "10px"
      ..fontSize = "24px"
      ..color = "#ff0000"
      ..cursor = "pointer";
    closeButton.addEventListener('click', ((web.Event _) => _userCancelledTransaction()).toJS);
    sdkDiv.append(closeButton);

    web.document.body?.append(outerDiv);

    /// Taking an instance of outer div to close it later
    _outerDiv = outerDiv;

    final environment = session["environment"] as String;
    final paymentSessionId = session["payment_session_id"] as String;

    final paymentComponents = arguments["paymentComponents"] as Map;
    final components = paymentComponents["components"] as List;
    final componentsToSend = <String>["order-details"];
    for (final component in components) {
      if (component == "wallet") {
        componentsToSend.add("app");
      } else if (component == "emi") {
        componentsToSend
          ..add("creditcardemi")
          ..add("cardlessemi");
      } else {
        componentsToSend.add(component.toString());
      }
    }

    // CFTheme is intentionally not forwarded. Every release up to 2.6.0+54
    // passed a raw Dart Map as `style`, which the JS SDK could not read, so the
    // web drop has always rendered Cashfree's default theme. Forwarding it now
    // would silently restyle every merchant's checkout (and in testing hid the
    // Pay button for the example theme). Make that a separate, tested change.
    _loadSdk(environment, () {
      final config = _CFConfig(
        components: componentsToSend.map((c) => c.toJS).toList().toJS,
        pluginName: _pluginName,
        onSuccess: ((JSString data) => onSuccess(data.toDart)).toJS,
        onFailure: ((JSString data) => onFailure(data.toDart)).toJS,
      );
      _Cashfree(paymentSessionId).drop(sdkDiv, config);
    });
  }
}
