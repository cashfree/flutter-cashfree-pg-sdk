class CFNetbankingBuilder {

  String? _channel = "link";
  int? _netbanking_bank_code;

  CFNetbankingBuilder();

  CFNetbankingBuilder setChannel(String channel) {
    _channel = channel;
    return this;
  }

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

  CFNetbanking build() {
    return CFNetbanking(this);
  }

}

class CFNetbanking {

  String? _channel = "link";
  int? _netbanking_bank_code;

  // Constructor
  CFNetbanking._();

  CFNetbanking(CFNetbankingBuilder builder) {
    _channel = builder.getChannel();
    _netbanking_bank_code = builder.getBankCode();
  }

  String getChannel() {
    return _channel!;
  }

  int getBankCode() {
    return _netbanking_bank_code!;
  }

}