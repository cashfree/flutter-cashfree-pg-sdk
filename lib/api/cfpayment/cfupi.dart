/// The UPI payment channel to use.
enum CFUPIChannel {
  /// UPI Collect flow — customer enters their UPI ID and receives a collect request.
  COLLECT,
  /// UPI Intent flow — launches an installed UPI app on the device.
  INTENT,
  /// UPI Intent flow with a built-in app-selection UI provided by the SDK.
  INTENT_WITH_UI
}

/// Builder for creating a [CFUPI] payment method object.
///
/// Example:
/// ```dart
/// final upi = CFUPIBuilder()
///   .setChannel(CFUPIChannel.COLLECT)
///   .setUPIID("user@upi")
///   .build();
/// ```
class CFUPIBuilder {

  CFUPIChannel? _channel;
  String? _upi_id;

  CFUPIBuilder();

  /// Sets the UPI channel (COLLECT, INTENT, or INTENT_WITH_UI).
  CFUPIBuilder setChannel(CFUPIChannel channel) {
    _channel = channel;
    return this;
  }

  /// Sets the customer's UPI ID (required for [CFUPIChannel.COLLECT]).
  CFUPIBuilder setUPIID(String upi_id) {
    _upi_id = upi_id;
    return this;
  }

  String getUPIID() {
    return _upi_id!;
  }

  CFUPIChannel getChannel() {
    return _channel!;
  }

  /// Builds and returns a [CFUPI] object.
  CFUPI build() {
    if(_channel == CFUPIChannel.INTENT_WITH_UI) {
      _upi_id = "";
    }
    return CFUPI(this);
  }

}

/// Represents a UPI payment method configuration.
///
/// Create instances using [CFUPIBuilder].
class CFUPI {

  CFUPIChannel? _channel;
  String? _upi_id;

  // Constructor
  CFUPI._();

  CFUPI(CFUPIBuilder builder) {
    _channel = builder.getChannel();
    _upi_id = builder.getUPIID();
  }

  /// Returns the customer's UPI ID.
  String getUPIID() {
    return _upi_id!;
  }

  /// Returns the selected [CFUPIChannel].
  CFUPIChannel getChannel() {
    return _channel!;
  }

}
