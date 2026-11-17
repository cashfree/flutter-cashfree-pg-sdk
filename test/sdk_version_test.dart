import 'dart:io';

import 'package:flutter_cashfree_pg_sdk/src/cf_sdk_version.dart';
import 'package:flutter_test/flutter_test.dart';

/// cfSdkVersion is reported to Cashfree (web pluginName) and must move with
/// every release. These checks fail the build if it drifts from the
/// published version or from the version the iOS plugin reports.
void main() {
  test('cfSdkVersion matches pubspec.yaml version (without build number)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec.yaml has no version line');
    expect(cfSdkVersion, match!.group(1));
  });

  test('cfSdkVersion matches iOS plugin versionNumber', () {
    final swift = File('ios/Classes/SwiftFlutterCashfreePgSdkPlugin.swift').readAsStringSync();
    final match = RegExp(r'versionNumber\s*=\s*"([^"]+)"').firstMatch(swift);
    expect(match, isNotNull, reason: 'iOS plugin has no versionNumber');
    expect(cfSdkVersion, match!.group(1));
  });
}
