import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/CFEnums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class Utils {

  static Utils? _instance;
  Utils._internal();

  static Utils? getInstance() {
    _instance ??= Utils._internal();
    return _instance;
  }

  static String orderId = "order_18482EymoaHdJ9PAwYU0onekw72KYzM";
  static String orderToken = "uEa5ZeOcWAbopeDtACKD";
  static CFEnvironment environment = CFEnvironment.PRODUCTION;

  static CFSession? createSession() {
    try {
      var session = CFSessionBuilder().setEnvironment(environment).setOrderId(Utils.orderId).setOrderToken(Utils.orderToken).build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

}