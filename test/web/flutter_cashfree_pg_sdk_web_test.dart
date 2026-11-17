@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

/// Stand-in for https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.*.js.
/// It exposes the same global shape (`window.CFFlutter.Cashfree`) and records
/// what the plugin hands over, so the test exercises the real JS interop path.
const String _stubSdk = '''
window.__cf = { sessions: [], configs: [], redirects: [] };
window.CFFlutter = {
  Cashfree: function (sessionId) {
    window.__cf.sessions.push(sessionId);
    this.drop = function (el, cfg) { window.__cf.configs.push({ el: el, cfg: cfg }); };
    this.redirect = function () { window.__cf.redirects.push(sessionId); };
  }
};
''';

final String _stubUrl =
    'data:text/javascript;base64,${base64.encode(utf8.encode(_stubSdk))}';

JSObject get _cf => web.window.getProperty<JSObject>('__cf'.toJS);
JSArray<JSAny?> _list(String name) => _cf.getProperty<JSArray<JSAny?>>(name.toJS);

/// 0 until the stub SDK script has loaded and created `window.__cf`.
int _count(String name) =>
    web.window.getProperty<JSAny?>('__cf'.toJS) != null ? _list(name).toDart.length : 0;

Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition not met within 2s');
}

Map<String, Object?> _dropArgs({List<Object?> components = const ['card', 'wallet', 'emi']}) {
  // Mirrors the payload CFPaymentGatewayService builds, after it has gone
  // through StandardMethodCodec (so maps are Map<Object?, Object?>).
  return <Object?, Object?>{
    'session': <Object?, Object?>{
      'environment': 'SANDBOX',
      'order_id': 'order_123',
      'payment_session_id': 'session_abc',
    },
    'paymentComponents': <Object?, Object?>{'components': components},
    'theme': <Object?, Object?>{
      'navigationBarBackgroundColor': '#6A3FD3',
      'navigationBarTextColor': '#FFFFFF',
      'primaryFont': 'Menlo',
    },
  }.cast<String, Object?>();
}

void main() {
  // One instance for the whole file, as registerWith creates in a real app.
  final plugin = FlutterCashfreePgSdkWeb();
  late List<String> verified;
  late List<(CFErrorResponse, String)> errors;

  setUp(() {
    FlutterCashfreePgSdkWeb.sdkScriptUrlOverride = (_) => _stubUrl;
    web.window.delete('__cf'.toJS);
    verified = [];
    errors = [];
    CFPaymentGatewayService.verifyPayment = verified.add;
    CFPaymentGatewayService.onError = (e, id) => errors.add((e, id));
  });

  tearDown(() {
    web.document.getElementById('cf-outer-div')?.remove();
    FlutterCashfreePgSdkWeb.sdkScriptUrlOverride = null;
  });

  test('unknown method throws Unimplemented', () async {
    expect(
      () => plugin.handleMethodCall(const MethodCall('doUPIPayment')),
      throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'Unimplemented')),
    );
  });

  test('sdk script url picks sandbox vs prod (no trailing space)', () {
    FlutterCashfreePgSdkWeb.sdkScriptUrlOverride = null;
    expect(FlutterCashfreePgSdkWeb.sdkScriptUrl('SANDBOX'),
        'https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.sandbox.js');
    expect(FlutterCashfreePgSdkWeb.sdkScriptUrl('PRODUCTION'),
        'https://sdk.cashfree.com/js/flutter/2.0.0/cashfree.prod.js');
  });

  test('doPayment mounts overlay and passes mapped config to Cashfree.drop', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);

    expect(web.document.getElementById('cf-outer-div'), isNotNull);
    expect(_list('sessions').toDart.last, 'session_abc'.toJS);

    final entry = _list('configs').toDart.single! as JSObject;
    final el = entry.getProperty<web.Element>('el'.toJS);
    expect(el.id, 'cf-flutter-placeholder');

    final cfg = entry.getProperty<JSObject>('cfg'.toJS);
    final components = cfg.getProperty<JSArray<JSString>>('components'.toJS).toDart.map((s) => s.toDart);
    expect(components, ['order-details', 'card', 'app', 'creditcardemi', 'cardlessemi']);

    // Parity with every release up to 2.6.0+54: the legacy plugin passed a raw
    // Dart Map as `style`, which the JS SDK could not read, so the web drop
    // always rendered Cashfree's default theme. Do not send a style until
    // honouring CFTheme on web is a deliberate, separately-tested change.
    expect(cfg.getProperty<JSAny?>('style'.toJS), isNull);
    expect(cfg.getProperty<JSString>('pluginName'.toJS).toDart, isNotEmpty);
    expect(cfg.getProperty<JSAny?>('onSuccess'.toJS).typeofEquals('function'), isTrue);
    expect(cfg.getProperty<JSAny?>('onFailure'.toJS).typeofEquals('function'), isTrue);
  });

  test('onSuccess from JS calls verifyPayment and removes overlay', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);
    final cfg = (_list('configs').toDart.single! as JSObject).getProperty<JSObject>('cfg'.toJS);

    cfg.callMethod('onSuccess'.toJS, jsonEncode({'order': {'orderId': 'order_123', 'status': 'PAID'}}).toJS);

    expect(verified, ['order_123']);
    expect(errors, isEmpty);
    expect(web.document.getElementById('cf-outer-div'), isNull);
  });

  test('onFailure with transaction calls onError with txMsg', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);
    final cfg = (_list('configs').toDart.single! as JSObject).getProperty<JSObject>('cfg'.toJS);

    cfg.callMethod('onFailure'.toJS, jsonEncode({
      'order': {'orderId': 'order_123'},
      'transaction': {'txMsg': 'Insufficient funds'},
    }).toJS);

    expect(verified, isEmpty);
    expect(errors.single.$1.getMessage(), 'Insufficient funds');
    expect(errors.single.$2, 'order_123');
    expect(web.document.getElementById('cf-outer-div'), isNull);
  });

  test('onFailure for inactive order calls onError', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);
    final cfg = (_list('configs').toDart.single! as JSObject).getProperty<JSObject>('cfg'.toJS);

    cfg.callMethod('onFailure'.toJS, jsonEncode({
      'order': {'orderId': 'order_123', 'errorText': 'Order is no longer active'},
    }).toJS);

    expect(errors.single.$1.getMessage(), 'Order is no longer active');
    expect(web.document.getElementById('cf-outer-div'), isNull);
  });

  test('onFailure with other message shows toast and keeps overlay', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);
    final cfg = (_list('configs').toDart.single! as JSObject).getProperty<JSObject>('cfg'.toJS);

    cfg.callMethod('onFailure'.toJS, jsonEncode({
      'order': {'orderId': 'order_123', 'errorText': 'Invalid card number'},
    }).toJS);

    expect(errors, isEmpty);
    final overlay = web.document.getElementById('cf-outer-div');
    expect(overlay, isNotNull);
    expect(overlay!.textContent, contains('Invalid card number'));
  });

  test('close button reports user cancellation with order id', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    final close = web.document.getElementById('cf-close-button') as web.HTMLElement;
    close.click();

    expect(errors.single.$1.getMessage(), 'Transaction cancelled by user');
    expect(errors.single.$2, 'order_123');
    expect(web.document.getElementById('cf-outer-div'), isNull);
  });

  test('hashchange reports cancellation only once per payment', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    web.window.dispatchEvent(web.HashChangeEvent('hashchange'));
    web.window.dispatchEvent(web.HashChangeEvent('hashchange'));

    expect(errors.length, 1);
    expect(errors.single.$1.getMessage(), 'Transaction cancelled by user');
  });

  test('hashchange after a successful payment does not report cancellation', () async {
    await plugin.handleMethodCall(MethodCall('doPayment', _dropArgs()));
    await _waitFor(() => _count('configs') == 1);
    final cfg = (_list('configs').toDart.single! as JSObject).getProperty<JSObject>('cfg'.toJS);
    cfg.callMethod('onSuccess'.toJS, jsonEncode({'order': {'orderId': 'order_123'}}).toJS);

    web.window.dispatchEvent(web.HashChangeEvent('hashchange'));

    expect(verified, ['order_123']);
    expect(errors, isEmpty);
  });

  test('doWebPayment loads sdk and calls Cashfree.redirect', () async {
    await plugin.handleMethodCall(MethodCall('doWebPayment', _dropArgs()));
    await _waitFor(() => _count('redirects') == 1);
    expect(_list('redirects').toDart.single, 'session_abc'.toJS);
  });
}
