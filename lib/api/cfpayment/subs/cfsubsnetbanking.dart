import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CFSubsNetbankingBuilder {

  String? _channel = "link";
  String? _auth_mode;
  String? _account_holder_name;
  String? _account_number;
  String? _account_type;
  String? _account_bank_code;

  CFSubsNetbankingBuilder();

  CFSubsNetbankingBuilder setAuthMode(String authMode) {
    _auth_mode = authMode;
    return this;
  }

  CFSubsNetbankingBuilder setAccountHolderName(String accountHolderName) {
    _account_holder_name = accountHolderName;
    return this;
  }

  CFSubsNetbankingBuilder setAccountNumber(String accountNumber) {
    _account_number = accountNumber;
    return this;
  }

  CFSubsNetbankingBuilder setAccountType(String accountType) {
    _account_type = accountType;
    return this;
  }

  CFSubsNetbankingBuilder setAccountBankCode(String accountBankCode) {
    _account_bank_code = accountBankCode;
    return this;
  }

  String getChannel() {
    return _channel!;
  }

  String? getAuthMode() {
    return _auth_mode;
  }

  String? getAccountHolderName() {
    return _account_holder_name;
  }

  String? getAccountNumber() {
    return _account_number;
  }

  String? getAccountType() {
    return _account_type;
  }

  String? getAccountBankCode() {
    return _account_bank_code;
  }

  CFSubsNetbanking build() {
    if (_auth_mode == null || _auth_mode!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_AUTH_MODE_NOT_PRESENT);
    }
    if (_account_holder_name == null || _account_holder_name!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_ACCOUNT_HOLDER_NAME_NOT_PRESENT);
    }
    if (_account_number == null || _account_number!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_ACCOUNT_NUMBER_NOT_PRESENT);
    }
    if (_account_type == null || _account_type!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_ACCOUNT_TYPE_NOT_PRESENT);
    }
    if (_account_bank_code == null || _account_bank_code!.isEmpty) {
      throw CFException(CFExceptionConstants.SUBSCRIPTION_NETBANKING_ACCOUNT_BANK_CODE_NOT_PRESENT);
    }
    return CFSubsNetbanking(this);
  }

}

class CFSubsNetbanking {

  late String _channel;
  late String _auth_mode;
  late String _account_holder_name;
  late String _account_number;
  late String _account_type;
  late String _account_bank_code;

  CFSubsNetbanking._();

  CFSubsNetbanking(CFSubsNetbankingBuilder builder) {
    _channel = builder.getChannel();
    _auth_mode = builder.getAuthMode()!;
    _account_holder_name = builder.getAccountHolderName()!;
    _account_number = builder.getAccountNumber()!;
    _account_type = builder.getAccountType()!;
    _account_bank_code = builder.getAccountBankCode()!;
  }

  String getChannel() {
    return _channel;
  }

  String getAuthMode() {
    return _auth_mode;
  }

  String getAccountHolderName() {
    return _account_holder_name;
  }

  String getAccountNumber() {
    return _account_number;
  }

  String getAccountType() {
    return _account_type;
  }

  String getAccountBankCode() {
    return _account_bank_code;
  }

}