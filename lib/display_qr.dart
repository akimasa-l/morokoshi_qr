import 'package:flutter/material.dart';
import "paypayclasses.dart";
import 'package:qr_flutter/qr_flutter.dart';
import "dart:convert";
import "paypaysecret.dart";

class DisplayQRContainer extends StatelessWidget {
  const DisplayQRContainer({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const DisplayQR();
  }
}

class DisplayQR extends StatefulWidget {
  const DisplayQR({Key? key}) : super(key: key);
  @override
  State<DisplayQR> createState() => _DisplayQRState();
}

class _DisplayQRState extends State<DisplayQR> {
  @override
  void initState() {
    super.initState();
  }

  bool isQRCodeCreated = false;
  String url = "";
  String response = "まだ押してないかも";

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a merchantPaymentId',
            ),
            controller: _controller,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final String merchantPaymentId = _controller.text;
            final String res = await payPayClient.createQRCode(
              CreateQRCodeBody(
                merchantPaymentId: merchantPaymentId,
                amount: const MoneyAmount(amount: 5),
                requestedAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
                orderItems: const [
                  OrderItem(
                    name: "nashio",
                    quantity: 2,
                    unitPrice: MoneyAmount(amount: 2),
                  ),
                  OrderItem(
                    name: "morokoshi",
                    quantity: 1,
                    unitPrice: MoneyAmount(amount: 1),
                  ),
                ],
              ),
            );
            setState(() {
              response = res;
              url = json.decode(response)["data"]["url"];
              isQRCodeCreated = true;
            });
          },
          child: const Text("Submit"),
        ),
        Text(
          response,
          textAlign: TextAlign.center,
        ),
        if (isQRCodeCreated)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: QrImage(
              data: url,
              semanticsLabel: "PayPayの支払いQRコード",
            ),
          ),
      ],
    );
  }
}
