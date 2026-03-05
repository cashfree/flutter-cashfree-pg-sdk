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
                    "order_id": "devstudio_7399366199638283385",
                    "environment": "SANDBOX",
                    "payment_session_id":
                        "session_zhSMCaiBnGBIeGhid2yREJyLEwWt4Cu369VfhcUntBs-aNhD6pcN9eLhBlQ6fPGaLaQxAkg_G-jNKOQ2m1PLsm0HYSXVI4Oa4dXae7uSE5A3-gadq5SLJ-CeFIQpayment"
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
