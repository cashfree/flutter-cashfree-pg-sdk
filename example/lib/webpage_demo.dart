import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/flutter_cashfree_pg_sdk_web.dart';

class PaymentTestPage extends StatelessWidget {
  final FlutterCashfreePgSdkWeb sdk = FlutterCashfreePgSdkWeb();

  PaymentTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashfree Web SDK Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                sdk.doWebPayment({
                  "session": {
                    "order_id": "devstudio_7445082824618121191",
                    "environment": "SANDBOX",
                    "payment_session_id":
                        "session_-Id_12RVU-Y_-Up1v-HrsP5KOm7I97K4Jpw_fl2nH4tPpvP1ec9VRMtPYr46EZN5AP1l3lRKBOMjrLwcdQMz4pIbGjf-UBzjgWtlZia3hEYpyJyAHISIpbaN6NUpayment"
                  }
                });
              },
              child: const Text('Test doWebPayment'),
            ),
          ],
        ),
      ),
    );
  }
}
