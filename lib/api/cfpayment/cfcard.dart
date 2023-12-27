import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';

class CFCardBuilder {

  String? _card_expiry_month;
  String? _card_expiry_year;
  String? _card_cvv;
  String? _card_holder_name;
  String? _instrument_id;
  CFCardWidget? _card_widget;

  CFCardBuilder();

  CFCardBuilder setCardExpiryMonth(String card_expiry_month) {
    _card_expiry_month = card_expiry_month;
    return this;
  }

  CFCardBuilder setCardExpiryYear(String card_expiry_year) {
    _card_expiry_year = card_expiry_year;
    return this;
  }

  CFCardBuilder setCardCVV(String card_cvv) {
    _card_cvv = card_cvv;
    return this;
  }

  CFCardBuilder setCardHolderName(String card_holder_name) {
    _card_holder_name = card_holder_name;
    return this;
  }

  CFCardBuilder setCardWidget(CFCardWidget card_widget) {
    _card_widget = card_widget;
    return this;
  }

  CFCardBuilder setInstrumentId(String instrument_id) {
    _instrument_id = instrument_id;
    return this;
  }

  String getCardExpiryMonth() {
    return _card_expiry_month ?? "";
  }

  String getCardExpiryYear() {
    return _card_expiry_year ?? "";
  }

  String getCardCvv() {
    return _card_cvv ?? "";
  }

  String getCardHolderName() {
    return _card_holder_name ?? "";
  }

  CFCardWidget? getCardNumber() {
    return _card_widget;
  }

  String? getInstrumentId() {
    return _instrument_id;
  }

  CFCard build() {
    return CFCard(this);
  }

}

class CFCard {

  String? _card_expiry_month;
  String? _card_expiry_year;
  String? _card_cvv;
  String? _card_holder_name;
  String? _instrument_id;
  CFCardWidget? _card_widget;

  // Constructor
  CFCard._();

  CFCard(CFCardBuilder builder) {
    _card_expiry_month = builder.getCardExpiryMonth();
    _card_expiry_year = builder.getCardExpiryYear();
    _card_cvv = builder.getCardCvv();
    _card_holder_name = builder.getCardHolderName();
    _card_widget = builder.getCardNumber();
    _instrument_id = builder.getInstrumentId();
  }

  String? getInstrumentId() {
    return _instrument_id;
  }

  String getCardExpiryMonth() {
    return _card_expiry_month ?? "";
  }

  String getCardExpiryYear() {
    return _card_expiry_year ?? "";
  }

  String getCardCvv() {
    return _card_cvv ?? "";
  }

  String getCardHolderName() {
    return _card_holder_name ?? "";
  }

  CFCardWidget? getCardNumber() {
    return _card_widget;
  }

}