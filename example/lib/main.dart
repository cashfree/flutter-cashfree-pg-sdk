import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardlistener.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcardpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbankingpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfsubscriptioncheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupipayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsubssession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfupi/cfupiutils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'webpage_demo.dart';

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
  var clientIDController = TextEditingController();
  var clientSecretController = TextEditingController();

  var TAG = "CashfreeFlutterSampleApp";

  CFCardWidget? cfCardWidget;

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
    final GlobalKey<CFCardWidgetState> myWidgetKey =
        GlobalKey<CFCardWidgetState>();
    try {
      var session = createSession();
      cfCardWidget = CFCardWidget(
        key: myWidgetKey,
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
      for (var i = 0; i < (value?.length ?? 0); i++) {
        var a = value?[i]["id"] as String ?? "";
        if (a.contains("cashfree")) {
          upiPackageName = value?[i]["id"];
          print("$TAG-------UPI PackageName ==> $upiPackageName");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Cashfree Flutter Sample app'),
      ),
      body: Center(
        child: Builder(
          builder: (context) => Column(
            children: [
              // Container(
              //   height: 500,
              //   width: 500,
              //   child: WebViewWidget(controller: controller),
              // )
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: clientIDController
                    ..text = "TEST430329ae80e0f32e41a393d78b923034",
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'Enter AppId',
                    contentPadding: const EdgeInsets.all(15.0),
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: clientSecretController
                      ..text = "TESTaf195616268bd6202eeb3bf8dc458956e7192a85",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      hintText: 'Enter App Secret',
                      contentPadding: const EdgeInsets.all(15.0),
                    ),
                  )),
              TextButton(onPressed: pay, child: const Text("Drop Pay flow")),
              TextButton(
                  onPressed: webCheckout,
                  child: const Text("Web Checkout Flow")),
              TextButton(
                  onPressed: upiIntentCheckout,
                  child: const Text("UPI Intent Checkout")),
              TextButton(
                  onPressed: () => susbcriptionCheckout(context),
                  child: const Text("Subscription Web Checkout Flow")),
              cfCardWidget!,
              TextButton(onPressed: cardPay, child: const Text("Card Pay")),
              TextButton(
                  onPressed: upiCollectPay,
                  child: const Text("UPI Collect Pay")),
              TextButton(
                  onPressed: upiIntentPay, child: const Text("UPI Intent Pay")),
              TextButton(
                  onPressed: netbankingPay,
                  child: const Text("Netbanking Pay")),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentTestPage(),
                    ),
                  );
                },
                child: const Text('Open Web Dart Page Demo'),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // "var cardNumber = document.createElement('div');\ncardNumber.id = \"cardNumber\";\nvar cardCvv = document.createElement('div');\ncardCvv.id = \"cardCvv\";\nvar cardExpiry = document.createElement('div');\ncardExpiry.id = \"cardExpiry\";\nvar cardHolder = document.createElement('div');\ncardHolder.id = \"cardHolder\";\nvar payButton = document.createElement('button');\npayButton.id = \"payButton\";\n\n\nconst cashfree = await load({ \n      mode: \"sandbox\", //or production\n    });\n\n    const cardComponent = cashfree.create(\"cardNumber\", {});\n    cardComponent.mount(\"#cardNumber\");\n\n    const cardCvv = cashfree.create(\"cardCvv\", {});\n    cardCvv.mount(\"#cardCvv\");\n\n    const cardExpiry = cashfree.create(\"cardExpiry\", {});\n    cardExpiry.mount(\"#cardExpiry\");\n\n    const cardHolder = cashfree.create(\"cardHolder\", {});\n    cardHolder.mount(\"#cardHolder\");\n\n    const showError = function(e){\n      alert(e.message)\n    }\n\n    document.querySelector(\"#payBtn\").addEventListener(\"click\", async () => {\n      cashfree.pay({\n        paymentMethod: cardComponent,\n        paymentSessionId: \"yourPaymentSession\",\n        returnUrl: \"https://merchantsite.com/return?order_id={order_id}\",\n      }).then(function (data) {\n        if (data != null && data.error) {\n          return showError(data.error)\n        }\n      });\n    })"

  void verifyPayment(String orderId) {
    print("$TAG --------Verify Payment ===> $orderId" );
    showToast("Verify Order ID ==> $orderId");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print("$TAG --------Error while making payment ===> $orderId");
    print("$TAG -------- ${errorResponse.getMessage()}");
    showToast("${errorResponse.getMessage()}");
  }

  void cardListener(CFCardListener cardListener) {
    print("$TAG --------Card Listener triggered");
    print(cardListener.getNumberOfCharacters());
    print(cardListener.getType());
    print(cardListener.getMetaData());
  }

  String orderId = "devstudio_7353735872386483514";
  String paymentSessionId =
      "session_Box0WGk2C4RgEItAmk0mOhYAikmLzkdJ3k8rjQ74dy4AIoFu-WHDmLZ8BxJOaK3KC3GmnMX31KJ98Ei_y51EEG-w7CKJxOKB9Cm6-M58CQIFGliIZnSAHWEHtX8payment";

  void receivedEvent(String event_name, Map<dynamic, dynamic> meta_data) {
    print(event_name);
    print(meta_data);
  }

  CFEnvironment environment = CFEnvironment.SANDBOX;
  String upiPackageName = "";

  upiIntentCheckout() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var upi = CFUPIBuilder().setChannel(CFUPIChannel.INTENT_WITH_UI).build();
      var upiPayment =
          CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiCollectPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var upi = CFUPIBuilder()
          .setChannel(CFUPIChannel.COLLECT)
          .setUPIID("testfailure@gocash")
          .build();
      var upiPayment =
          CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  netbankingPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var netbanking =
          CFNetbankingBuilder().setChannel("link").setBankCode(3003).build();
      var netbankingPayment = CFNetbankingPaymentBuilder()
          .setSession(session!)
          .setNetbanking(netbanking)
          .build();
      cfPaymentGatewayService.doPayment(netbankingPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiIntentPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var upi = CFUPIBuilder()
          .setChannel(CFUPIChannel.INTENT)
          .setUPIID(upiPackageName)
          .build();
      var upiPayment =
          CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  cardPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var card = CFCardBuilder()
          .setCardWidget(cfCardWidget!)
          .setCardExpiryMonth("08")
          .setCardExpiryYear("88")
          .setCardHolderName("Roronoa Zoro")
          .setCardCVV("888")
          .build();
      var cardPayment = CFCardPaymentBuilder()
          .setSession(session!)
          .setCard(card)
          .savePaymentMethod(true)
          .build();
      cfPaymentGatewayService.doPayment(cardPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  pay() async {
    try {
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent =
          CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#FF0000")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session!)
          .setPaymentComponent(paymentComponent)
          .setTheme(theme)
          .build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  CFSession? createSession() {
    try {
      String oid = orderId;
      String spi = paymentSessionId;
      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(oid)
          .setPaymentSessionId(spi)
          .build();
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
      var session = await createPaymentSession();
      if (session == null) {
        print("$TAG -------- Order creation failed");
        showToast("Order Session creation failed");
        return;
      }
      var cfWebCheckout =
          CFWebCheckoutPaymentBuilder().setSession(session!).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  susbcriptionCheckout(BuildContext context) async {
    try {
      cfPaymentGatewayService.setCallback(
          onSubscriptionVerify, onSubscriptionFailure);
      var session = await createSubscriptionSession();
      if (session == null) {
        print("$TAG -------- Subscription Session creation failed");
        showToast("Subscription Session creation failed");
        return;
      }
      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#ffffff")
          .setNavigationBarTextColor("#ffffff")
          .build();
      var cfsubscriptionCheckout = CFSubscriptionPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();
      cfPaymentGatewayService.doPayment(cfsubscriptionCheckout);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  Future<CFSubscriptionSession?> createSubscriptionSession() async {
    const uuid = Uuid();
    final String subscriptionId = 'sub_${uuid.v4()}';
    final url = Uri.parse('https://sandbox.cashfree.com/pg/subscriptions');

    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-api-version': '2023-08-01',
      'x-client-id': clientIDController.text,
      'x-client-secret': clientSecretController.text,
    };

    final body = jsonEncode({
      "customer_details": {
        "customer_name": "Mukul Jain",
        "customer_email": "mukul.jain@cashfree.com",
        "customer_phone": "8810643608"
      },
      "plan_details": {"plan_id": "plan_12344"},
      "authorization_details": {
        "authorization_amount": 1,
        "authorization_amount_refund": true
      },
      "subscription_meta": {
        "return_url": "https://wa.me/9512440440?text=Payment%20Successfull",
        "notification_channel": ["EMAIL", "SMS"]
      },
      "subscription_id": subscriptionId,
      "subscription_note": "testSUBB",
      "subscription_expiry_time": "2026-01-14T23:00:08+05:30",
      "notificationChannels": ["EMAIL", "SMS"]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final subscriptionSessionId = data['subscription_session_id'];
        final subscriptionId = data['subscription_id'];
        var subsriptionSession = CFSubscriptionSessionBuilder()
            .setEnvironment(environment)
            .setSubscriptionId(subscriptionId)
            .setSubscriptionSessionId(subscriptionSessionId)
            .build();
        return subsriptionSession;
      } else {
        print(
            "$TAG -------- Failed to create subscription: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("$TAG -------- Exception during subscription creation: $e");
    }

    return null;
  }

  Future<CFSession?> createPaymentSession() async {
    final url = Uri.parse('https://sandbox.cashfree.com/pg/orders');

    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-api-version': '2025-01-01',
      'x-client-id': clientIDController.text,
      'x-client-secret': clientSecretController.text,
    };

    final body = jsonEncode({
      "order_amount": 1.00,
      "order_currency": "INR",
      "customer_details": {
        "customer_id": "rand_order_id",
        "customer_name": "Cashfree Sample",
        "customer_email": "test@cashfree.digital",
        "customer_phone": "8474090552"
      },
      "order_meta": {
        "return_url":
            "https://www.cashfree.com/devstudio/preview/pg/web/checkout?order_id={order_id}"
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paymentSessionId = data['payment_session_id'];
        final orderId = data['order_id'];
        var cfSession = CFSessionBuilder()
            .setEnvironment(environment)
            .setOrderId(orderId)
            .setPaymentSessionId(paymentSessionId)
            .build();
        return cfSession;
      } else {
        print(
            "$TAG -------- Failed to create order: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("$TAG -------- Exception during order creation: $e");
    }

    return null;
  }

  void onSubscriptionVerify(String subscriptionId) {
    print("$TAG -------- Verify Subscription ===> $subscriptionId");
    showToast("Verify Subs ID ==> $subscriptionId");
  }

  void onSubscriptionFailure(CFErrorResponse errorResponse, String data) {
    print("$TAG -------- Failure in subscription flow");
    print(errorResponse.getMessage());
    showToast(errorResponse.getMessage());
  }

  void showToast(String? message) {
    Fluttertoast.showToast(
        msg: "$message",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
