/// Plugin version reported to Cashfree for analytics (web `pluginName`).
///
/// Bump on every release. It must equal the pubspec.yaml `version` (without
/// the build number) and `versionNumber` in the iOS plugin;
/// test/sdk_version_test.dart fails the build if they drift.
const String cfSdkVersion = "2.7.0";
