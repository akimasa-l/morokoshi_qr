import "package:flutter/material.dart";
import 'package:morokoshi_qr/pay_finish_button.dart';
import 'package:url_launcher/url_launcher.dart';
import "dart:async";
import "dart:convert";
import "morokoshi_future_builder.dart";
import "package:http/http.dart" as http;

enum SquareTenderTypes {
  creditCard,
  cash,
  other,
  squareGiftCard,
  cardOnFile,
}

extension on List<SquareTenderTypes> {
  Iterable<String> toJson() sync* {
    for (final tenderType in this) {
      switch (tenderType) {
        case SquareTenderTypes.creditCard:
          yield "CREDIT_CARD";
          break;
        case SquareTenderTypes.cash:
          yield "CASH";
          break;
        case SquareTenderTypes.other:
          yield "OTHER";
          break;
        case SquareTenderTypes.squareGiftCard:
          yield "SQUARE_GIFT_CARD";
          break;
        case SquareTenderTypes.cardOnFile:
          yield "CARD_ON_FILE";
          break;
      }
    }
  }
}

class SquareMoneyAmount {
  final int amount;
  final String currency_code;
  const SquareMoneyAmount({required this.amount, this.currency_code = "JPY"});
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency_code': currency_code,
      };
}

class SquarePayOptions {
  final bool auto_return;
  final bool skip_receipt;
  final bool clear_default_fees;
  final bool disable_cnp;
  final List<SquareTenderTypes> supported_tender_types;
  const SquarePayOptions({
    this.auto_return = true,
    this.skip_receipt = true,
    this.clear_default_fees = false,
    this.disable_cnp = true,
    this.supported_tender_types = SquareTenderTypes.values,
  });
  Map<String, dynamic> toJson() => {
        'auto_return': auto_return,
        'skip_receipt': skip_receipt,
        'clear_default_fees': clear_default_fees,
        'disable_cnp': disable_cnp,
        'supported_tender_types': supported_tender_types.toJson().toList(),
      };
}

class SquarePay {
  static const sdk_version = "3.5.0";
  static const version = "1.3";
  final String client_id;
  final SquareMoneyAmount amount_money;
  final String callback_url;
  final String location_id;
  final String notes;
  final SquarePayOptions options;
  // final String state;// userInfoStringって呼ばれてたところ // リーカーはnilを入れてたから別に入れなくてもいいのかもね
  // final String customer_id; // リーカーはnilを入れてたから別に入れなくてもいいのかもね

  const SquarePay({
    required this.client_id,
    required this.amount_money,
    required this.callback_url,
    required this.location_id,
    required this.notes,
    required this.options,
  });
  // toJson()
  Map<String, dynamic> toJson() => {
        'client_id': client_id,
        'amount_money': amount_money,
        'callback_url': callback_url,
        'location_id': location_id,
        'notes': notes,
        'options': options,
        "sdk_version": sdk_version,
        "version": version,
      };

  /// わんちゃんObjective-Cがカスなせいで[callback_url]のところを
  /// ふつうは
  ///  ```dart
  /// "food-register-app://square_request"
  /// ```
  ///  にしたいところを
  /// ```dart
  /// "food-register-app:\\/\\/square_request"
  /// ```
  /// みたいな感じに
  /// しなければならないかもです
  /// てかこの後ろの
  /// ```dart
  /// "square_request"
  /// ```
  /// はいったいなんなんだろうな
  Future<void> pay() async {
    await launch(
        "square-commerce-v1://payment/create?data=${Uri.encodeComponent(jsonEncode(toJson()))}");
    '{"notes":"聖光祭食品店舗 フランクフルト","callback_url":"food-register-app:\\/\\/square_request","location_id":"LJRBXB2HKP93T","version":"1.3","amount_money":{"amount":350,"currency_code":"JPY"},"options":{"auto_return":true,"skip_receipt":true,"clear_default_fees":false,"disable_cnp":true,"supported_tender_types":["CREDIT_CARD","CASH","OTHER","SQUARE_GIFT_CARD","CARD_ON_FILE"]},"client_id":"sq0idp-qiwKd4g26Tpdlw5eY1QFdQ","sdk_version":"3.5.0"}';
  }
}

class SquareFinish extends StatelessWidget {
  const SquareFinish({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Squareの決済完了！")),
      body: SingleChildScrollView(
        child: MorokoshiFutureBuilder<String>(
          future: () async {
            // ここを決済が完了したことをデータベースに残しておく
            await http.get(Uri.https("google.com", "/"));
            return "google.com";
          }(),
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${snapshot.data}",
                ),
                const PayFinishButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}
