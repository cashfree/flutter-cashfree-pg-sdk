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
                    "order_id": "devstudio_7360984143259511930",
                    "environment": "SANDBOX",
                    "payment_session_id":
                        "session_oYPv3Q25MxYjGBC8tnaJvgiAbUhl6gpx825zBg6PK0Ge6fO9GlxvsvsSslRwrID0NysrRBX0HExgAQj90Y0Pg2CO90rIMkKtogKR8r2KKTQQTDQjd837sBsCNikpayment"
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
