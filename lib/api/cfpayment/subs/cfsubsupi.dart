import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

enum CFSubsUPIChannel {
  INTENT
}


class CFSubsUPIBuilder {

  CFSubsUPIChannel? _channel;
  String? _upi_id;

  CFSubsUPIBuilder();

  CFSubsUPIBuilder setChannel(CFSubsUPIChannel channel) {
    _channel = channel;
    return this;
  }

  CFSubsUPIBuilder setUPIID(String upiId) {
    _upi_id = upiId;
    return this;
  }

  String getUPIID() {
    return _upi_id!;
  }

  CFSubsUPIChannel getChannel() {
    return _channel!;
  }

  CFSubsUPI build() {
    if (_channel == null) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_UPI_CHANNEL_NOT_PRESENT);
    }
    if (_upi_id == null || _upi_id!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_UPI_ID_NOT_PRESENT);
    }
    return CFSubsUPI(this);
  }

}

class CFSubsUPI {

  late CFSubsUPIChannel _channel;
  late String _upi_id;

  CFSubsUPI._();

  CFSubsUPI(CFSubsUPIBuilder builder) {
    _channel = builder.getChannel();
    _upi_id = builder.getUPIID();
  }

  String getUPIID() {
    return _upi_id;
  }

  CFSubsUPIChannel getChannel() {
    return _channel;
  }

}