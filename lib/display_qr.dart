import 'package:flutter/material.dart';
import "paypayclasses.dart";
import 'package:qr_flutter/qr_flutter.dart';
import "dart:convert";
import "paypaysecret.dart";

class DisplayQRContainer extends StatelessWidget {
  final CreateQRCodeBody createQRCodeBody;
  const DisplayQRContainer({
    Key? key,
    required this.createQRCodeBody,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("PayPayで支払う"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: DisplayQR(
            createQRCodeBody: createQRCodeBody,
          ),
        ),
      ),
    );
  }
}

class DisplayQR extends StatefulWidget {
  final CreateQRCodeBody createQRCodeBody;
  const DisplayQR({
    Key? key,
    required this.createQRCodeBody,
  }) : super(key: key);
  @override
  State<DisplayQR> createState() => _DisplayQRState();
}

class _DisplayQRState extends State<DisplayQR> {
  late final CreateQRCodeBody _createQRCodeBody;
  @override
  void initState() {
    super.initState();
    _createQRCodeBody = widget.createQRCodeBody;
  }

  bool isQRCodeCreated = false;
  String url = "";
  String response = "まだレスポンスが帰ってきてないかも";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final String res = await payPayClient.createQRCode(
              /* CreateQRCodeBody(
                merchantPaymentId:
                    DateTime.now().millisecondsSinceEpoch.toString(),
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
              ), */
              _createQRCodeBody,
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
              size: 300.0,
              data: url,
              semanticsLabel: "PayPayの支払いQRコード",
            ),
          ),
      ],
    );
  }
}
