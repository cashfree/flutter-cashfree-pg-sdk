enum CFUPIChannel {
  COLLECT,
  INTENT,
  INTENT_WITH_UI
}

class CFUPIBuilder {

  CFUPIChannel? _channel;
  String? _upi_id;

  CFUPIBuilder();

  CFUPIBuilder setChannel(CFUPIChannel channel) {
    _channel = channel;
    return this;
  }

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

  CFUPI build() {
    if(_channel == CFUPIChannel.INTENT_WITH_UI) {
      _upi_id = "";
    }
    return CFUPI(this);
  }

}

class CFUPI {

  CFUPIChannel? _channel;
  String? _upi_id;

  // Constructor
  CFUPI._();

  CFUPI(CFUPIBuilder builder) {
    _channel = builder.getChannel();
    _upi_id = builder.getUPIID();
  }

  String getUPIID() {
    return _upi_id!;
  }

  CFUPIChannel getChannel() {
    return _channel!;
  }

}