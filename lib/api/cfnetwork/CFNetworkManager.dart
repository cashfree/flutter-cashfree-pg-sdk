import 'dart:convert';

import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:http/http.dart' as http;

class CFNetworkManager {
  static final CFNetworkManager _singleton = CFNetworkManager._internal();

  factory CFNetworkManager() {
    return _singleton;
  }

  CFNetworkManager._internal();

  Future<http.Response> getTDR(CFSession session, String bin) async {
    var url = "api.cashfree.com";
    if(session.getEnvironmentEnum() == CFEnvironment.SANDBOX) {
      url = "sandbox.cashfree.com";
    }
    var uri = Uri.https(url, '/pg/sdk/js/${session.getPaymentSessionId()}/v2/tdr');
    var response = await http.post(uri, body: jsonEncode({
      "code": bin,
      "code_type": "bin"
    }), headers: {
      "Content-Type": "application/json"
    });
    return response;
  }

  Future<http.Response> getCardBin(CFSession session, String bin) async {
    var url = "api.cashfree.com";
    if(session.getEnvironmentEnum() == CFEnvironment.SANDBOX) {
      url = "sandbox.cashfree.com";
    }
    var uri = Uri.https(url, '/pg/sdk/js/${session.getPaymentSessionId()}/cardBin');
    var response = await http.post(uri, body: jsonEncode({
      "card_number": bin,
    }), headers: {
      "Content-Type": "application/json"
    });
    return response;
  }
}