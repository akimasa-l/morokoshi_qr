import "package:flutter/material.dart";
import 'paypay_classes.dart';
import 'paypay_display_qr.dart';
import 'dart:math';
import "morokoshi_cached_network_image.dart";
import "morokoshi_stream_builder.dart";
import "square_pay.dart";
import "square_secret.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class FoodInfo {
  final int unitPrice;
  final String name, imageUrl;
  const FoodInfo({
    required this.unitPrice,
    required this.name,
    required this.imageUrl,
  });
  FoodInfo.fromMap(Map<String, dynamic> map)
      : assert(map['unitPrice'] != null),
        assert(map['name'] != null),
        assert(map['imageUrl'] != null),
        assert(map['name'] is String),
        assert(map['imageUrl'] is String),
        assert(map['unitPrice'] is int),
        unitPrice = map['unitPrice'],
        name = map['name'],
        imageUrl = map['imageUrl'];

  Map<String, dynamic> toMap() {
    return {
      'unitPrice': unitPrice,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

class FoodCount {
  int _count;
  final FoodInfo foodInfo;
  FoodCount({
    int count = 0,
    required this.foodInfo,
  }) : _count = count;
  FoodCount.fromMap(Map<String, dynamic> map)
      : assert(map['unitPrice'] != null),
        assert(map['name'] != null),
        assert(map['imageUrl'] != null),
        assert(map['name'] is String),
        assert(map['imageUrl'] is String),
        assert(map['unitPrice'] is int),
        _count = 0,
        foodInfo = FoodInfo(
          unitPrice: map['unitPrice'],
          name: map['name'],
          imageUrl: map['imageUrl'],
        );
  int get count => _count;
  set count(int after) {
    if (after >= 0) {
      _count = after;
    }
  }

  @override
  String toString() {
    return count.toString();
  }

  PayPayOrderItem toPayPayOrderItem() {
    return PayPayOrderItem(
      name: foodInfo.name,
      unitPrice: PayPayMoneyAmount(amount: foodInfo.unitPrice),
      quantity: count,
    );
  }

  Map<String, dynamic> toJson() => {
        'unitPrice': foodInfo.unitPrice,
        'name': foodInfo.name,
        'count': count,
        'imageUrl': foodInfo.imageUrl,
      };
}

class FoodWidget extends StatelessWidget {
  final FoodCount foodCount;
  const FoodWidget({
    Key? key,
    required this.foodCount,
    required this.increment,
    required this.decrement,
  }) : super(key: key);

  final void Function() increment, decrement;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 300,
      width: 250,
      child: Card(
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      foodCount.foodInfo.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      '${foodCount.foodInfo.unitPrice}円',
                      // style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              MorokoshiCachedNetworkImage(
                imageUrl: foodCount.foodInfo.imageUrl,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton(
                      heroTag: Random()
                          .nextDouble()
                          .toString(), // uniqueなheroTagをつけなきゃいけないらしい
                      child: const Icon(
                        Icons.remove,
                        color: Colors.black,
                      ),
                      onPressed: decrement,
                      backgroundColor: Colors.white,
                    ),
                    Text(
                      '${foodCount.count}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    FloatingActionButton(
                      heroTag: Random()
                          .nextDouble()
                          .toString(), // uniqueなheroTagをつけなきゃいけないらしい
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      onPressed: increment,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension GetFoodAmount on List<FoodCount> {
  int get amount => fold(
        0,
        (int acc, FoodCount foodCount) =>
            acc + foodCount.count * foodCount.foodInfo.unitPrice,
      );
}

class FoodWidgets extends StatefulWidget {
  const FoodWidgets({
    Key? key,
    required this.foods,
    required this.shopName,
  }) : super(key: key);
  final List<FoodCount> foods;
  final String shopName;
  @override
  State<FoodWidgets> createState() => _FoodWidgetsState();
}

class _FoodWidgetsState extends State<FoodWidgets> {
  late final List<FoodCount> _foods;
  late final String _shopName;
  @override
  void initState() {
    super.initState();
    _foods = widget.foods;
    _shopName = widget.shopName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // https://qiita.com/kikuchy/items/1c95e1a3b2300ff44d21
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (final foodCount in _foods)
                        FoodWidget(
                          foodCount: foodCount,
                          increment: () {
                            setState(() {
                              foodCount.count++;
                            });
                          },
                          decrement: () {
                            setState(() {
                              foodCount.count--;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text("商品名"),
                          ),
                          DataColumn(
                            label: Text("単価"),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text("個数"),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text("合計"),
                            numeric: true,
                          ),
                        ],
                        rows: <DataRow>[
                          for (final foodCount in _foods)
                            if (foodCount.count > 0)
                              //　ここあるとボタンの位置が変わっちゃうんだよな
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Text(foodCount.foodInfo.name),
                                  ),
                                  DataCell(
                                    Text('${foodCount.foodInfo.unitPrice}円'),
                                  ),
                                  DataCell(
                                    Text('${foodCount.count}'),
                                    // showEditIcon: true,
                                    onTap: () {
                                      setState(() {
                                        foodCount.count = 0;
                                      });
                                    },
                                  ),
                                  DataCell(
                                    Text(
                                        '${foodCount.foodInfo.unitPrice * foodCount.count}円'),
                                  ),
                                ],
                              ),
                          DataRow(
                            cells: <DataCell>[
                              const DataCell(
                                Text('合計'),
                              ),
                              const DataCell(
                                Text('-'),
                              ),
                              DataCell(
                                Text(
                                  '${_foods.fold(0, (int a, FoodCount b) => a + b.count)}個',
                                ), //これGitHub Copilotが書いてくれたんだけど　すげえ
                              ),
                              DataCell(
                                Text(
                                  '${_foods.amount}円',
                                ), //これも　プログラマーはもういらないわ
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:8.0),
                    child: Wrap(direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PayPayDisplayQRContainer(
                                    payPayCreateQRCodeBody:
                                        PayPayCreateQRCodeBody(
                                      merchantPaymentId: DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      orderItems: _foods
                                          .where((FoodCount f) => f.count > 0)
                                          .map((FoodCount f) =>
                                              f.toPayPayOrderItem())
                                          .toList(),
                                      amount: PayPayMoneyAmount(
                                          amount: _foods.amount),
                                      requestedAt: (DateTime.now()
                                              .millisecondsSinceEpoch ~/
                                          1000),
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                tag: "PayPay",
                                child:
                                    Image.asset("images/paypay.png", width: 32),
                              ),
                            ),
                            label: const Text("PayPayで支払う"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SquarePay(
                                client_id: squareClientID,
                                amount_money: SquareMoneyAmount(
                                  amount: _foods.amount,
                                ),
                                callback_url: squareCallbackURL,
                                location_id: squareLocationID,
                                notes: _shopName,
                                options: const SquarePayOptions(),
                              ).pay();
                            },
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                tag: "Square",
                                child:
                                    Image.asset("images/square.png", width: 32),
                              ),
                            ),
                            label: const Text("Squareで支払う"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CreatePayment extends StatelessWidget {
  const CreatePayment({
    Key? key,
    required this.foodInfoCollectionReference,
    required this.shopName,
  }) : super(key: key);
  final CollectionReference<FoodInfo> foodInfoCollectionReference;
  final String shopName;

  @override
  Widget build(BuildContext context) {
    return MorokoshiStreamBuilder<FoodInfo>(
      stream: foodInfoCollectionReference.snapshots(),
      builder: (context, snapshot) {
        return FoodWidgets(
          shopName: shopName,
          foods: <FoodCount>[
            for (final document in snapshot.data!.docs)
              FoodCount(foodInfo: document.data()),
          ],
        );
      },
    );
  }
}
