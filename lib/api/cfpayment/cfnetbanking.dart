/// Builder for creating a [CFNetbanking] payment method object.
///
/// Example:
/// ```dart
/// final netbanking = CFNetbankingBuilder()
///   .setBankCode(3003)
///   .build();
/// ```
class CFNetbankingBuilder {

  String? _channel = "link";
  int? _netbanking_bank_code;

  CFNetbankingBuilder();

  /// Sets the payment channel. Defaults to `"link"`.
  CFNetbankingBuilder setChannel(String channel) {
    _channel = channel;
    return this;
  }

  /// Sets the bank code for the selected netbanking bank.
  CFNetbankingBuilder setBankCode(int bank_code) {
    _netbanking_bank_code = bank_code;
    return this;
  }

  String getChannel() {
    return _channel!;
  }

  int getBankCode() {
    return _netbanking_bank_code!;
  }

  /// Builds and returns a [CFNetbanking] object.
  CFNetbanking build() {
    return CFNetbanking(this);
  }

}

/// Represents a netbanking payment method configuration.
///
/// Create instances using [CFNetbankingBuilder].
class CFNetbanking {

  String? _channel = "link";
  int? _netbanking_bank_code;

  // Constructor
  CFNetbanking._();

  CFNetbanking(CFNetbankingBuilder builder) {
    _channel = builder.getChannel();
    _netbanking_bank_code = builder.getBankCode();
  }

  /// Returns the payment channel string.
  String getChannel() {
    return _channel!;
  }

  /// Returns the bank code for the selected netbanking bank.
  int getBankCode() {
    return _netbanking_bank_code!;
  }

}
