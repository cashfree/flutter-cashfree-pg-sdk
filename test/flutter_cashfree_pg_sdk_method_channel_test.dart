// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk_method_channel.dart';
//
// void main() {
//   MethodChannelFlutterCashfreePgSdk platform = MethodChannelFlutterCashfreePgSdk();
//   const MethodChannel channel = MethodChannel('flutter_cashfree_pg_sdk');
//
//   TestWidgetsFlutterBinding.ensureInitialized();
//
//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       return '42';
//     });
//   });
//
//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });
//
//   test('getPlatformVersion', () async {
//     expect(await platform.getPlatformVersion(), '42');
//   });
// }
