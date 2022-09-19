// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk.dart';
// import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk_platform_interface.dart';
// import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockFlutterCashfreePgSdkPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterCashfreePgSdkPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final FlutterCashfreePgSdkPlatform initialPlatform = FlutterCashfreePgSdkPlatform.instance;
//
//   test('$MethodChannelFlutterCashfreePgSdk is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterCashfreePgSdk>());
//   });
//
//   test('getPlatformVersion', () async {
//     FlutterCashfreePgSdk flutterCashfreePgSdkPlugin = FlutterCashfreePgSdk();
//     MockFlutterCashfreePgSdkPlatform fakePlatform = MockFlutterCashfreePgSdkPlatform();
//     FlutterCashfreePgSdkPlatform.instance = fakePlatform;
//
//     expect(await flutterCashfreePgSdkPlugin.getPlatformVersion(), '42');
//   });
// }
