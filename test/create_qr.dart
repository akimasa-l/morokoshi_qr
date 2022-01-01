import 'package:morokoshi_qr/paypayclasses.dart';
import "package:morokoshi_qr/paypaysecret.dart";
import "package:flutter/material.dart";

Future<void> main() async {
  debugPrint(await payPayClient.createQRCode(
    CreateQRCodeBody(
      merchantPaymentId: "aaaaa",
      amount: const MoneyAmount(amount: 4),
      requestedAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  ));
  // print(await payPayClient.getPaymentDetails(merchantPaymentId: "m"));
}
