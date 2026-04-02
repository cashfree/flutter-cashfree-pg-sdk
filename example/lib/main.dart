import 'dart:io';

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
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubscard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubscardpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsnetbankingpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/subs/cfsubsupipayment.dart';
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

  // Subs UPI
  var subsUPIIdController = TextEditingController();

  // Subs Netbanking
  String selectedAuthMode = "net_banking";
  final List<String> authModeOptions = ["net_banking", "aadhaar", "debit_card"];
  var subsNBAccountHolderController = TextEditingController(text: "John Doe");
  var subsNBAccountNumberController = TextEditingController(text: "112233445");
  var subsNBAccountTypeController = TextEditingController(text: "SAVINGS");
  var subsNBBankCodeController = TextEditingController(text: "UTIB");

  // Subs Card
  var subsCardNumberController = TextEditingController(text: "4111111111111111");
  var subsCardHolderController = TextEditingController(text: "Harshith");
  var subsCardExpiryMMController = TextEditingController(text: "08");
  var subsCardExpiryYYController = TextEditingController(text: "32");
  var subsCardCVVController = TextEditingController(text: "111");

  var TAG = "CashfreeFlutterSampleApp";

  CFCardWidget? cfCardWidget;

  @override
  void initState() {
    super.initState();
    subsUPIIdController.text = Platform.isAndroid ? "com.phonepe.app" : "phonepe://";
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
          contentPadding: const EdgeInsets.all(15.0),
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2.0,
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Credentials
              ExpansionTile(
                title: const Text('Credentials', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  _buildCompactTextField(clientIDController, 'App ID',
                      defaultText: "TEST430329ae80e0f32e41a393d78b923034"),
                  const SizedBox(height: 6),
                  _buildCompactTextField(clientSecretController, 'App Secret',
                      defaultText: "TESTaf195616268bd6202eeb3bf8dc458956e7192a85"),
                ],
              ),

              // Standard Flows
              ExpansionTile(
                title: const Text('Standard Flows', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 4.5,
                    children: [
                      _buildGridButton("PG Drop Flow", pay),
                      _buildGridButton("PG Web Checkout", webCheckout),
                      _buildGridButton("PG UPI Intent Checkout", upiIntentCheckout),
                      _buildGridButton("Subs Web Checkout", () => susbcriptionCheckout(context)),
                      _buildGridButton("PG UPI Collect", upiCollectPay),
                      _buildGridButton("PG UPI Intent", upiIntentPay),
                      _buildGridButton("PG Netbanking", netbankingPay),
                    ],
                  ),
                ],
              ),

              // PG Card
              ExpansionTile(
                title: const Text('PG Card Pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  cfCardWidget!,
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cardPay,
                      child: const Text("Pay Now — PG Card"),
                    ),
                  ),
                ],
              ),

              // Subscription UPI
              ExpansionTile(
                title: const Text('Subscription UPI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  _buildCompactTextField(
                    subsUPIIdController,
                    Platform.isAndroid ? 'PSP Package (e.g. com.phonepe.app)' : 'URI Schema (e.g. phonepe://)',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: subsUPIPay,
                      child: const Text("Pay Now — Subs UPI"),
                    ),
                  ),
                ],
              ),

              // Subscription Netbanking
              ExpansionTile(
                title: const Text('Subscription Netbanking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedAuthMode,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Auth Mode',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    ),
                    items: authModeOptions
                        .map((mode) => DropdownMenuItem(value: mode, child: Text(mode, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (value) => setState(() => selectedAuthMode = value!),
                  ),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 3.2,
                    children: [
                      _buildGridTextField(subsNBAccountHolderController, 'Account Holder'),
                      _buildGridTextField(subsNBAccountNumberController, 'Account Number'),
                      _buildGridTextField(subsNBAccountTypeController, 'Account Type'),
                      _buildGridTextField(subsNBBankCodeController, 'Bank Code'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: subsNetbankingPay,
                      child: const Text("Pay Now — Subs Netbanking"),
                    ),
                  ),
                ],
              ),

              // Subscription Card
              ExpansionTile(
                title: const Text('Subscription Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 3.2,
                    children: [
                      _buildGridTextField(subsCardNumberController, 'Card Number'),
                      _buildGridTextField(subsCardHolderController, 'Card Holder'),
                      _buildGridTextField(subsCardExpiryMMController, 'Expiry MM'),
                      _buildGridTextField(subsCardExpiryYYController, 'Expiry YY'),
                      _buildGridTextField(subsCardCVVController, 'CVV'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: subsCardPay,
                      child: const Text("Pay Now — Subs Card"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTextField(TextEditingController controller, String hint, {String? defaultText}) {
    if (defaultText != null && controller.text.isEmpty) {
      controller.text = defaultText;
    }
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        isDense: true,
      ),
    );
  }

  Widget _buildGridTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        isDense: true,
      ),
    );
  }

  Widget _buildGridButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
    );
  }

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

  CFEnvironment environment = CFEnvironment.SANDBOX;
  String upiPackageName = "";

  // ─── Subscription UPI ────────────────────────────────────────────────────────

  subsUPIPay() async {
    try {
      cfPaymentGatewayService.setCallback(onSubscriptionVerify, onSubscriptionFailure);
      var session = await createSubscriptionSession();
      if (session == null) {
        showToast("Subscription Session creation failed");
        return;
      }
      var subsUPI = CFSubsUPIBuilder()
          .setChannel(CFSubsUPIChannel.INTENT)
          .setUPIID(subsUPIIdController.text)
          .build();
      var subsUPIPayment = CFSubsUPIPaymentBuilder()
          .setSession(session)
          .setUPI(subsUPI)
          .build();
      cfPaymentGatewayService.doPayment(subsUPIPayment);
    } on CFException catch (e) {
      print(e.message);
      showToast(e.message);
    }
  }

  // ─── Subscription Netbanking ─────────────────────────────────────────────────

  subsNetbankingPay() async {
    try {
      cfPaymentGatewayService.setCallback(onSubscriptionVerify, onSubscriptionFailure);
      var session = await createSubscriptionSession();
      if (session == null) {
        showToast("Subscription Session creation failed");
        return;
      }
      var subsNetbanking = CFSubsNetbankingBuilder()
          .setAuthMode(selectedAuthMode)
          .setAccountHolderName(subsNBAccountHolderController.text)
          .setAccountNumber(subsNBAccountNumberController.text)
          .setAccountType(subsNBAccountTypeController.text)
          .setAccountBankCode(subsNBBankCodeController.text)
          .build();
      var subsNetbankingPayment = CFSubsNetbankingPaymentBuilder()
          .setSession(session)
          .setNetbanking(subsNetbanking)
          .build();
      cfPaymentGatewayService.doPayment(subsNetbankingPayment);
    } on CFException catch (e) {
      print(e.message);
      showToast(e.message);
    }
  }

  // ─── Subscription Card ───────────────────────────────────────────────────────

  subsCardPay() async {
    try {
      cfPaymentGatewayService.setCallback(onSubscriptionVerify, onSubscriptionFailure);
      var session = await createSubscriptionSession();
      if (session == null) {
        showToast("Subscription Session creation failed");
        return;
      }
      var subsCard = CFSubsCardBuilder()
          .setCardNumber(subsCardNumberController.text)
          .setCardHolderName(subsCardHolderController.text)
          .setCardExpiryMM(subsCardExpiryMMController.text)
          .setCardExpiryYY(subsCardExpiryYYController.text)
          .setCardCVV(subsCardCVVController.text)
          .build();
      var subsCardPayment = CFSubsCardPaymentBuilder()
          .setSession(session)
          .setCard(subsCard)
          .build();
      cfPaymentGatewayService.doPayment(subsCardPayment);
    } on CFException catch (e) {
      print(e.message);
      showToast(e.message);
    }
  }

  // ─── Existing flows ──────────────────────────────────────────────────────────

  upiIntentCheckout() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = await createPaymentSession();
      if (session == null) {
        showToast("Order Session creation failed");
        return;
      }
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
      var session = await createPaymentSession();
      if (session == null) {
        showToast("Order Session creation failed");
        return;
      }
      var upi = CFUPIBuilder()
          .setChannel(CFUPIChannel.COLLECT)
          .setUPIID("testfailure@gocash")
          .build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
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
        showToast("Order Session creation failed");
        return;
      }
      var netbanking = CFNetbankingBuilder().setChannel("link").setBankCode(3003).build();
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
        showToast("Order Session creation failed");
        return;
      }
      var upi = CFUPIBuilder()
          .setChannel(CFUPIChannel.INTENT)
          .setUPIID(upiPackageName)
          .build();
      var upiPayment = CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
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
        showToast("Order Session creation failed");
        return;
      }
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent = CFPaymentComponentBuilder().setComponents(components).build();
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
      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  webCheckout() async {
    try {
      var session = await createPaymentSession();
      if (session == null) {
        showToast("Order Session creation failed");
        return;
      }
      var cfWebCheckout = CFWebCheckoutPaymentBuilder().setSession(session!).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  susbcriptionCheckout(BuildContext context) async {
    try {
      cfPaymentGatewayService.setCallback(onSubscriptionVerify, onSubscriptionFailure);
      var session = await createSubscriptionSession();
      if (session == null) {
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

  // ─── Session creation ─────────────────────────────────────────────────────────

  Future<CFSubscriptionSession?> createSubscriptionSession() async {
    const uuid = Uuid();
    final String subscriptionId = 'sub_${uuid.v4()}';
    final url = Uri.parse('https://sandbox.cashfree.com/pg/subscriptions');

    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-api-version': '2025-01-01',
      'x-client-id': clientIDController.text,
      'x-client-secret': clientSecretController.text,
    };

    final body = jsonEncode({
      "subscription_id": subscriptionId,
      "customer_details": {
        "customer_name": "Harshith",
        "customer_email": "test@cashfree.com",
        "customer_phone": "9876543210"
      },
      "plan_details": {
        "plan_name": "devstudio_subs_plan",
        "plan_type": "ON_DEMAND",
        "plan_currency": "INR",
        "plan_amount": 1,
        "plan_max_amount": 100,
        "plan_max_cycles": 0,
        "plan_note": "on demand INR 1 plan"
      },
      "authorization_details": {
        "authorization_amount": 1,
        "authorization_amount_refund": true
      },
      "subscription_meta": {
        "return_url": "https://www.cashfree.com/devstudio/preview/subs/seamless"
      },
      "subscription_expiry_time": "2027-03-31T10:19:58.227Z"
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CFSubscriptionSessionBuilder()
            .setEnvironment(environment)
            .setSubscriptionId(data['subscription_id'])
            .setSubscriptionSessionId(data['subscription_session_id'])
            .build();
      } else {
        print("$TAG -------- Failed to create subscription: ${response.statusCode} ${response.body}");
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
      "order_id": "devstudio_7445082824618121191",
      "customer_details": {
        "customer_id": "devstudio_user",
        "customer_phone": "9876543210"
      },
      "order_meta": {
        "return_url": "https://www.cashfree.com/devstudio/preview/pg/web/checkout?order_id={order_id}"
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CFSessionBuilder()
            .setEnvironment(environment)
            .setOrderId(data['order_id'])
            .setPaymentSessionId(data['payment_session_id'])
            .build();
      } else {
        print("$TAG -------- Failed to create order: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("$TAG -------- Exception during order creation: $e");
    }
    return null;
  }

  // ─── Callbacks ────────────────────────────────────────────────────────────────

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