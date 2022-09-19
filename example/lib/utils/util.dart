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

  static String orderId = "order_3242Eypmd5FgXn0CUfibZ5vWEfZ8GY";
  static String orderToken = "mAyIMOBjkB1ay0LcBm7K";
  static CFEnvironment environment = CFEnvironment.SANDBOX;

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