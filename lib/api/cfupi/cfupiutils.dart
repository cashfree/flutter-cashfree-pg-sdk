import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CFUPIUtils {

  /// This method returns the list of installed UPI applications
  Future<List?> getUPIApps() {
    Future<List?> response;

    if(kIsWeb) {
      var completer = Completer<List>();
      completer.complete(<dynamic>[]);
      response = completer.future;
    }
    MethodChannel channel = const MethodChannel("flutter_cashfree_pg_sdk");
    // ignore: unnecessary_null_comparison
    if(channel != null) {
      response = channel.invokeListMethod("getupiapps");
    } else {
      var completer = Completer<List>();
      completer.complete(<dynamic>[]);
      response = completer.future;
    }
    return response;
  }

}