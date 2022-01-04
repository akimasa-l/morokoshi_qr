import 'package:flutter/material.dart';
import "paypayclasses.dart";
import 'package:qr_flutter/qr_flutter.dart';
import "dart:async";
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
              DisplayQR(
                createQRCodeBody: createQRCodeBody,
              ),
              Text(
                "お支払い金額 : ${createQRCodeBody.amount.amount}円",
                style: Theme.of(context).textTheme.headline4,
              ),
              // 戻るボタン
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, "/",(_)=>false);
                },
                child: const Text("次のお支払いに進む"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayQR extends StatelessWidget {
  final CreateQRCodeBody createQRCodeBody;
  const DisplayQR({
    Key? key,
    required this.createQRCodeBody,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: payPayClient.createQRCode(
        createQRCodeBody,
      ), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          try {
            final url = json.decode(response)["data"]["url"];
            return Padding(
              padding: const EdgeInsets.all(100.0),
              child: QrImage(
                size: 300.0,
                data: url,
                semanticsLabel: "PayPayの支払いQRコード",
                embeddedImage: const AssetImage("images/paypay.png"),
              ),
            );
          } catch (e) {
            return Text("Response: $response\nError: ${e.toString()}");
          }
        }
        // それ以外のとき
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: "PayPay",
              child: Image.asset("images/paypay.png", width: 150),
            ),
            const CircularProgressIndicator(),
            Text(
              "Loading...",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        );
      },
    );
  }
}

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Text("aa");
  }
}


class PaymentDetailsStream {
  final String merchantPaymentId;
  final Duration duration;
  PaymentDetailsStream({
    required this.merchantPaymentId,
    this.duration = const Duration(seconds: 10),
  }) {
    Timer.periodic(duration, (_) async {
      final response = await payPayClient.getPaymentDetails(
        merchantPaymentId: merchantPaymentId,
      );
      _controller.sink.add(response);
    });
  }
  final _controller = StreamController<String>();
  Stream<String> get stream => _controller.stream;
}
