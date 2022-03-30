import "package:flutter/material.dart";
import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import 'shop_setting_screen.dart';
import 'payment_details.dart';

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
    return StreamBuilder<QuerySnapshot<Shop>>(
      stream: _shopsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("データ消えてるっぽいです。ごめんなさい。");
        }
        final docs = snapshot.data!.docs;
        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final document in docs) Text("data", document.reference)
          ],
        );
      },
    );
  }
}

class ShopSummary extends StatelessWidget {
  const ShopSummary({Key? key, required this.shopReference}) : super(key: key);
  final DocumentReference<Shop> shopReference;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    shopReference.collection("paymentDetails").withConverter<PaymentDetails>(
          fromFirestore: (snapshot, _) =>
              PaymentDetails.fromMap(snapshot.data()!),
          toFirestore: (paymentDetails, _) => paymentDetails.toMap(),
        );
    return const Text("aa");
  }
}
