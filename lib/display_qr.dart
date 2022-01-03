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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "PayPay",
                child: Image.asset("images/paypay.png", width: 200),
              ),
              DisplayQR(
                createQRCodeBody: createQRCodeBody,
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: payPayClient.createQRCode(
        _createQRCodeBody,
      ), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          try {
            final url = json.decode(response)["data"]["url"];
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: QrImage(
                size: 300.0,
                data: url,
                semanticsLabel: "PayPayの支払いQRコード",
              ),
            );
          } catch (e) {
            return Text("Response: $response\nError: ${e.toString()}");
          }
        }

        return Column(
          children: const <Widget>[
            CircularProgressIndicator(),
            Text("Loading..."),
          ],
        );
      },
    );
  }
}

