import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFSubsCardBuilder {

  String? _channel = "link";
  String? _card_number;
  String? _card_holder_name;
  String? _card_expiry_mm;
  String? _card_expiry_yy;
  String? _card_cvv;

  CFSubsCardBuilder();

  CFSubsCardBuilder setCardNumber(String cardNumber) {
    _card_number = cardNumber;
    return this;
  }

  CFSubsCardBuilder setCardHolderName(String cardHolderName) {
    _card_holder_name = cardHolderName;
    return this;
  }

  CFSubsCardBuilder setCardExpiryMM(String cardExpiryMM) {
    _card_expiry_mm = cardExpiryMM;
    return this;
  }

  CFSubsCardBuilder setCardExpiryYY(String cardExpiryYY) {
    _card_expiry_yy = cardExpiryYY;
    return this;
  }

  CFSubsCardBuilder setCardCVV(String cardCVV) {
    _card_cvv = cardCVV;
    return this;
  }

  String getChannel() {
    return _channel!;
  }

  String? getCardNumber() {
    return _card_number;
  }

  String? getCardHolderName() {
    return _card_holder_name;
  }

  String? getCardExpiryMM() {
    return _card_expiry_mm;
  }

  String? getCardExpiryYY() {
    return _card_expiry_yy;
  }

  String? getCardCVV() {
    return _card_cvv;
  }

  CFSubsCard build() {
    if (_card_number == null || _card_number!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_NUMBER_NOT_PRESENT);
    }
    if (_card_holder_name == null || _card_holder_name!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_HOLDER_NAME_NOT_PRESENT);
    }
    if (_card_expiry_mm == null || _card_expiry_mm!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_EXPIRY_MM_NOT_PRESENT);
    }
    if (_card_expiry_yy == null || _card_expiry_yy!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_EXPIRY_YY_NOT_PRESENT);
    }
    if (_card_cvv == null || _card_cvv!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_CARD_CVV_NOT_PRESENT);
    }
    return CFSubsCard(this);
  }

}

class CFSubsCard {

  late String _channel;
  late String _card_number;
  late String _card_holder_name;
  late String _card_expiry_mm;
  late String _card_expiry_yy;
  late String _card_cvv;

  CFSubsCard._();

  CFSubsCard(CFSubsCardBuilder builder) {
    _channel = builder.getChannel();
    _card_number = builder.getCardNumber()!;
    _card_holder_name = builder.getCardHolderName()!;
    _card_expiry_mm = builder.getCardExpiryMM()!;
    _card_expiry_yy = builder.getCardExpiryYY()!;
    _card_cvv = builder.getCardCVV()!;
  }

  String getChannel() {
    return _channel;
  }

  String getCardNumber() {
    return _card_number;
  }

  String getCardHolderName() {
    return _card_holder_name;
  }

  String getCardExpiryMM() {
    return _card_expiry_mm;
  }

  String getCardExpiryYY() {
    return _card_expiry_yy;
  }

  String getCardCVV() {
    return _card_cvv;
  }

}