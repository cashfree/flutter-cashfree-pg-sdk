import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupiintentcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var cfPaymentGatewayService = CFPaymentGatewayService();

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError, getUPIAppsCallback);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(onPressed: pay, child: const Text("Pay")),
              TextButton(onPressed: webCheckout, child: const Text("Web Checkout")),
              TextButton(onPressed: upiCheckout, child: const Text("UPI Intent Checkout")),
              TextButton(onPressed: getInstalledUPIApps, child: const Text("Get Installed UPI Apps"))
            ],
          ),
        ),
      ),
    );
  }

  void verifyPayment(String orderId) {
    print("Verify Payment");
  }
  void getUPIAppsCallback(List<Map<String, dynamic>> apps){
    print("getUPIAppsCallback");
    if (apps.isEmpty)
      print("Found No Apps");
    else
      print("Found ${apps.length} apps in the phone");
  }
  void onError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print("Error while making payment");
  }

  String orderId = "Order1221321231233186";
  String paymentSessionId = "session_bP8jq7MAaoI7RZrIGqiqGi__EKs26vbALGjvS3OW_XRwOSzF-_DsW09dJARGzh_PzXbTyXKvq90v1p-efsngy6rGJmB-mf2l3z_bg2Iud2if";
  CFEnvironment environment = CFEnvironment.SANDBOX;

  CFSession? createSession() {
    try {
      var session = CFSessionBuilder().setEnvironment(CFEnvironment.SANDBOX).setOrderId(orderId).setPaymentSessionId(paymentSessionId).build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  pay() async {
    try {
      var session = createSession();
      List<CFPaymentModes> components = <CFPaymentModes>[];
      var paymentComponent = CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder().setNavigationBarBackgroundColorColor("#FF0000").setPrimaryFont("Menlo").setSecondaryFont("Futura").build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder().setSession(session!).setPaymentComponent(paymentComponent).setTheme(theme).build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      print(e.message);
    }

  }

  webCheckout() async {
    try {
      var session = createSession();
      var cfWebCheckout = CFWebCheckoutPaymentBuilder().setSession(session!).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }

  }
  upiCheckout() async {
    try {
      var session = createSession();
      var cfUPIIntentCheckout = CFUPIIntentCheckoutPaymentBuilder().setSession(session!).setPackage("com.google.android.apps.nbu.paisa.user").build();
      cfPaymentGatewayService.doPayment(cfUPIIntentCheckout);
    } on CFException catch (e) {
      print(e.message);
    }

  }


  void getInstalledUPIApps() async {
    cfPaymentGatewayService.getInstalledUPIApps();
  }
}
