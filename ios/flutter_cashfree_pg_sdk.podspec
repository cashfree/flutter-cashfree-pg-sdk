#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_cashfree_pg_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_cashfree_pg_sdk'
  s.version          = '2.6.0'
  s.summary          = 'Cashfree Payment Gateway Flutter plugin.'
  s.description      = <<-DESC
Flutter plugin wrapping the Cashfree Payment Gateway iOS SDK.
                       DESC
  s.homepage         = 'http://cashfree.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Cashfree Payments' => 'developers@cashfree.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency "CashfreePG", "2.5.3"
end
