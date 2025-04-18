import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardlistener.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcardpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbankingpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupipayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfupi/cfupiutils.dart';

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

  CFCardWidget? cfCardWidget;

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
    final GlobalKey<CFCardWidgetState> myWidgetKey = GlobalKey<CFCardWidgetState>();
    try {
      var session = createSession();
      cfCardWidget = CFCardWidget(key: myWidgetKey,
        textStyle: null,
        inputDecoration: InputDecoration(
          hintText: 'XXXX XXXX XXXX XXXX',
          contentPadding: const EdgeInsets.all(15.0), // Adjust padding as needed
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
            borderSide: const BorderSide(
              color: Colors.green, // Set your desired tint color here
              width: 2.0, // Adjust the border width as needed
            ),
          ),
        ),
        cardListener: cardListener,
        cfSession: session,
      );
    } on CFException catch (e) {
      print(e.message);
    }

    CFUPIUtils().getUPIApps().then((value) {
      for(var i = 0; i < (value?.length ?? 0); i++) {
        print("UPI Icon base64Icon ==> ${value?[i]["base64Icon"]}");
        print("UPI Package Identifier ==>${value?[i]["id"]}");
        print("UPI App Name ==> ${value?[i]["displayName"]}");
        var a = value?[i]["id"] as String ?? "";
        if(a.contains("cashfree")) {
          upiPackageName = value?[i]["id"];
          print("UPI PackageName ==> $upiPackageName");
        }
      }
    });
  }

  // void clearCookies() {
  //   cookieManager.clearCookies();
  // }

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
              // Container(
              //   height: 500,
              //   width: 500,
              //   child: WebViewWidget(controller: controller),
              // )
              TextButton(onPressed: pay, child: const Text("Pay")),
              TextButton(onPressed: webCheckout, child: const Text("Web Checkout")),
              TextButton(onPressed: upiIntentCheckout, child: const Text("UPI Intent Checkout")),
              cfCardWidget!,
              TextButton(onPressed: cardPay, child: const Text("Card Pay")),
              TextButton(onPressed: upiCollectPay, child: const Text("UPI Collect Pay")),
              TextButton(onPressed: upiIntentPay, child: const Text("UPI Intent Pay")),
              TextButton(onPressed: netbankingPay, child: const Text("Netbanking Pay")),
            ],
          ),
        ),
      ),
    );
  }

  // "var cardNumber = document.createElement('div');\ncardNumber.id = \"cardNumber\";\nvar cardCvv = document.createElement('div');\ncardCvv.id = \"cardCvv\";\nvar cardExpiry = document.createElement('div');\ncardExpiry.id = \"cardExpiry\";\nvar cardHolder = document.createElement('div');\ncardHolder.id = \"cardHolder\";\nvar payButton = document.createElement('button');\npayButton.id = \"payButton\";\n\n\nconst cashfree = await load({ \n      mode: \"sandbox\", //or production\n    });\n\n    const cardComponent = cashfree.create(\"cardNumber\", {});\n    cardComponent.mount(\"#cardNumber\");\n\n    const cardCvv = cashfree.create(\"cardCvv\", {});\n    cardCvv.mount(\"#cardCvv\");\n\n    const cardExpiry = cashfree.create(\"cardExpiry\", {});\n    cardExpiry.mount(\"#cardExpiry\");\n\n    const cardHolder = cashfree.create(\"cardHolder\", {});\n    cardHolder.mount(\"#cardHolder\");\n\n    const showError = function(e){\n      alert(e.message)\n    }\n\n    document.querySelector(\"#payBtn\").addEventListener(\"click\", async () => {\n      cashfree.pay({\n        paymentMethod: cardComponent,\n        paymentSessionId: \"yourPaymentSession\",\n        returnUrl: \"https://merchantsite.com/return?order_id={order_id}\",\n      }).then(function (data) {\n        if (data != null && data.error) {\n          return showError(data.error)\n        }\n      });\n    })"

  void verifyPayment(String orderId) {
    print("Verify Payment");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print("Error while making payment");
    print(errorResponse.getMessage());
  }

  void cardListener(CFCardListener cardListener) {
    print("Card Listener triggered");
    print(cardListener.getNumberOfCharacters());
    print(cardListener.getType());
    print(cardListener.getMetaData());
  }

  String orderId = "devstudio_7318157564499795298";
  String paymentSessionId = "session_GPXQ9UXdmPZPYNaENynIezYeoEK1kZkmMnR8fDPtYH2mJgS_dqIENfGw9k3rRNjpXW8PfgpdTDXIr6-q6TSTxCL9oE0DRzVrnaySGR5Q-h8NxEiwpg6DpdcOYIMpayment";
  void receivedEvent(String event_name, Map<dynamic, dynamic> meta_data) {
    print(event_name);
    print(meta_data);
  }

  CFEnvironment environment = CFEnvironment.SANDBOX;
  String upiPackageName = "";

  upiIntentCheckout() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.INTENT_WITH_UI).build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiCollectPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.COLLECT).setUPIID("suhasg6@ybl").build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  netbankingPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var netbanking = CFNetbankingBuilder().setChannel("link").setBankCode(3003).build();
      var netbankingPayment = CFNetbankingPaymentBuilder().setSession(session!).setNetbanking(netbanking).build();
      cfPaymentGatewayService.doPayment(netbankingPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiIntentPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.INTENT).setUPIID(upiPackageName).build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  cardPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var card = CFCardBuilder().setCardWidget(cfCardWidget!).setCardExpiryMonth("08").setCardExpiryYear("88").setCardHolderName("Roronoa Zoro").setCardCVV("888").build();
      var cardPayment = CFCardPaymentBuilder().setSession(session!).setCard(card).savePaymentMethod(true).build();
      cfPaymentGatewayService.doPayment(cardPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  pay() async {
    try {
      var session = createSession();
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent = CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder().setNavigationBarBackgroundColorColor("#FF0000").setPrimaryFont("Menlo").setSecondaryFont("Futura").build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder().setSession(session!).setPaymentComponent(paymentComponent).setTheme(theme).build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      print(e.message);
    }

  }

  CFSession? createSession() {
    try {
      String oid = orderId;
      String spi = paymentSessionId;
      var session = CFSessionBuilder().setEnvironment(environment).setOrderId(oid).setPaymentSessionId(spi).build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  newPay() async {
    cfPaymentGatewayService = CFPaymentGatewayService();
    cfPaymentGatewayService.setCallback((p0) async {
      print(p0);
    }, (p0, p1) async {
      print(p0);
      print(p1);
    });
    webCheckout();
  }

  webCheckout() async {
    try {
      var session = createSession();
      var theme = CFThemeBuilder().setNavigationBarBackgroundColorColor("#ffffff").setNavigationBarTextColor("#ffffff").build();
      var cfWebCheckout = CFWebCheckoutPaymentBuilder().setSession(session!).setTheme(theme).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }

  }

}
