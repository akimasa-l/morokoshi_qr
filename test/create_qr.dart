import 'package:morokoshi_qr/paypay_classes.dart';
import 'package:morokoshi_qr/paypay_secret.dart';
import "package:flutter/material.dart";

Future<void> main() async {
  debugPrint(await payPayClient.createQRCode(
    PayPayCreateQRCodeBody(
      merchantPaymentId: "aaaaa",
      amount: const PayPayMoneyAmount(amount: 4),
      requestedAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  ));
  // print(await payPayClient.getPaymentDetails(merchantPaymentId: "m"));
}
