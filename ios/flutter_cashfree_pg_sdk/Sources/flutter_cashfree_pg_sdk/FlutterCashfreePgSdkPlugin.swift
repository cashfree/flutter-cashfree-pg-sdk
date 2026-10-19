import Flutter

/// Swift Package Manager entry point.
///
/// Flutter's generated registrant calls `[FlutterCashfreePgSdkPlugin registerWithRegistrar:]`, the
/// `pluginClass` from pubspec.yaml. Under CocoaPods that class is the Objective-C shim in
/// `ios/Classes`, which forwards to `SwiftFlutterCashfreePgSdkPlugin`. SwiftPM targets cannot mix
/// Objective-C and Swift, so this package instead exposes the same name as a subclass of the
/// shared Swift implementation. This file exists only in the SwiftPM package; the shared source
/// next to it is a symlink into `ios/Classes`, so CocoaPods is unaffected.
@objc(FlutterCashfreePgSdkPlugin)
public final class FlutterCashfreePgSdkPlugin: SwiftFlutterCashfreePgSdkPlugin {}
