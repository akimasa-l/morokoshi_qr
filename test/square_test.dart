import "dart:convert";
import "package:flutter/material.dart";
import "package:morokoshi_qr/square_pay.dart";

void main() {
  const squarePay = SquarePay(
    client_id: "client_id",
    amount_money: MoneyAmount(amount: 1000),
    callback_url: "callback_url",
    location_id: "location_id",
    notes: "notes",
    options: SquarePayOptions(),
  );
  debugPrint(jsonEncode(squarePay));
}
