import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardlistener.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcardpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
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
    );

    CFUPIUtils().getUPIApps().then((value) {
      selectedId = value?.first["id"];
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
              cfCardWidget!,
              TextButton(onPressed: cardPay, child: const Text("Card Pay")),
              TextButton(onPressed: upiCollectPay, child: const Text("UPI Collect Pay")),
              TextButton(onPressed: upiIntentPay, child: const Text("UPI Intent Pay")),
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
    print(errorResponse.getMessage());
    print("Error while making payment");
  }

  void cardListener(CFCardListener cardListener) {
    print("Card Listener triggered");
    print(cardListener.getNumberOfCharacters());
    print(cardListener.getType());
  }

  String orderId = "order_3242UhxUiidPwO0QOkPHPCgm4jkprP";
  String paymentSessionId = "session_IHBtfcvm2qz9MXc_K2Hfc6IO_a_XExwJyAONGKbLU5fy3HR7sMDbfgSYZuSLnHmBgPtmLDY4gqumbTskfA61bDvTICXBQRB3js2MuoHi3nk2";
  void receivedEvent(String event_name, Map<dynamic, dynamic> meta_data) {
    print(event_name);
    print(meta_data);
  }

  // String orderId = "order_18482TC1GWfnEYW3gheFhy4mArfynXh";
  // String paymentSessionId = "session_gMej8P4gvNUKLbd3fGWVw7Njg5fj3KK4We0HjCg6Tkzy5yZ8mkghdv7vKels1CJ8fBz9_aVpSoU8n5rqufVQrexzhLW0g0dzgdiTJwmrkZYn";

  // String orderId = "order_18482OupTxSofcClBAlgqyYxUVceHo8";
  // String paymentSessionId = "session_oeYlKCusKyW5pND4Swzn1rE2-gwnoM8MOC2nck9RjIiUQwXcPLWB3U1xHaaItb-uA9H1k6Fwziq9O63DWcfYGy_3B7rl1nDFo3MMeVqiYrBr";
  CFEnvironment environment = CFEnvironment.SANDBOX;
  String selectedId = "";

  upiCollectPay() async {
    try {
      var session = createSession();
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.COLLECT).setUPIID("test@ybl").build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiIntentPay() async {
    try {
      var session = createSession();
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.INTENT).setUPIID(selectedId).build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  cardPay() async {
    try {
      var session = createSession();
      var card = CFCardBuilder().setCardWidget(cfCardWidget!).setCardCVV("123").setCardExpiryMonth("12").setCardExpiryYear("25").setCardHolderName("Test").build();
      var cardPayment = CFCardPaymentBuilder().setSession(session!).setCard(card).build();
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
      var session = CFSessionBuilder().setEnvironment(environment).setOrderId(orderId).setPaymentSessionId(paymentSessionId).build();
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
      //var theme = CFThemeBuilder().setNavigationBarBackgroundColorColor("#ff00ff").setNavigationBarTextColor("#ffffff").build();
      var cfWebCheckout = CFWebCheckoutPaymentBuilder().setSession(session!).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }

  }

}
