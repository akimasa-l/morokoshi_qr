import "package:flutter/material.dart";
import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "order_screen.dart";
import 'shop_setting_screen.dart';
import 'payment_details.dart';
import 'morokoshi_stream_builder.dart';

class Summary extends StatelessWidget {
  const Summary({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Shop>> _shopsStream = FirebaseFirestore.instance
        .collection('shops')
        .withConverter<Shop>(
          fromFirestore: (snapshot, _) => Shop.fromMap(snapshot.data()!),
          toFirestore: (shop, _) => shop.toMap(),
        )
        .snapshots();
    return MorokoshiStreamBuilder<Shop>(
      stream: _shopsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data!.docs;
        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final document in docs)
              ShopSummary(shopReference: document.reference),
          ],
        );
      },
    );
  }
}

class ShopSummary extends StatelessWidget {
  static Map<PayType, int> paymentSum(
      List<QueryDocumentSnapshot<PaymentDetails>> docs) {
    final a = {for (final payType in PayType.values) payType: 0};
    for (final doc in docs) {
      final paymentDetails = doc.data();
      a[paymentDetails.payType] =
          paymentDetails.foodCount.amount + a[paymentDetails.payType]!;
      // +=は何故か使えないんですね～
    }
    return a;
  }

  const ShopSummary({Key? key, required this.shopReference}) : super(key: key);
  final DocumentReference<Shop> shopReference;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final paymentDetailsSnapshot = shopReference
        .collection("paymentDetails")
        .withConverter<PaymentDetails>(
          fromFirestore: (snapshot, _) =>
              PaymentDetails.fromMap(snapshot.data()!),
          toFirestore: (paymentDetails, _) => paymentDetails.toMap(),
        )
        .snapshots();
    return MorokoshiStreamBuilder<PaymentDetails>(
      stream: paymentDetailsSnapshot,
      builder: (context, snapshot) {
        final docs = snapshot.data!.docs;
        return Text("今の所合計：${paymentSum(docs)}");
      },
    );
  }
}
