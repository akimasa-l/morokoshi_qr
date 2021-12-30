import "package:flutter/material.dart";
import 'paypayclasses.dart';
import "display_qr.dart";

class FoodInfo {
  int _count;
  final int unitPrice;
  final String name, imagePath;
  FoodInfo({
    int count = 0,
    required this.unitPrice,
    required this.name,
    required this.imagePath,
  }) : _count = count;
  FoodInfo.fromMap(Map<String, dynamic> map)
      : assert(map['unitPrice'] != null),
        assert(map['name'] != null),
        assert(map['imagePath'] != null),
        assert(map['name'] is String),
        assert(map['imagePath'] is String),
        assert(map['unitPrice'] is int),
        _count = 0,
        unitPrice = map['unitPrice'],
        name = map['name'],
        imagePath = map['imagePath'];
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

  OrderItem toOrderItem() {
    return OrderItem(
      name: name,
      unitPrice: MoneyAmount(amount: unitPrice),
      quantity: count,
    );
  }
}

class FoodWidget extends StatelessWidget {
  final FoodInfo foodInfo;
  const FoodWidget({
    Key? key,
    required this.foodInfo,
    required this.increment,
    required this.decrement,
  }) : super(key: key);

  final void Function() increment, decrement;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 300,
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      foodInfo.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      '${foodInfo.unitPrice}円',
                      // style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Image.asset(
                foodInfo.imagePath,
                // width: 100,
                // height: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton(
                      child: const Icon(
                        Icons.remove,
                        color: Colors.black,
                      ),
                      onPressed: decrement,
                      backgroundColor: Colors.white,
                    ),
                    Text(
                      '${foodInfo.count}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    FloatingActionButton(
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

class FoodWidgets extends StatefulWidget {
  const FoodWidgets({
    Key? key,
    required this.foods,
  }) : super(key: key);
  final List<FoodInfo> foods;
  @override
  State<FoodWidgets> createState() => _FoodWidgetsState();
}

class _FoodWidgetsState extends State<FoodWidgets> {
  late final List<FoodInfo> _foods;
  @override
  void initState() {
    super.initState();
    _foods = widget.foods;
  }

  int amount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceAround,
          runAlignment: WrapAlignment.spaceAround,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final foodInfo in _foods)
              FoodWidget(
                foodInfo: foodInfo,
                increment: () {
                  setState(() {
                    foodInfo.count++;
                  });
                },
                decrement: () {
                  setState(() {
                    foodInfo.count--;
                  });
                },
              ),
          ],
        ),
        Padding(
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
              for (final foodInfo in _foods)
                if (foodInfo.count > 0)
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(foodInfo.name),
                      ),
                      DataCell(
                        Text('${foodInfo.unitPrice}円'),
                      ),
                      DataCell(
                        Text('${foodInfo.count}'),
                        // showEditIcon: true,
                        onTap: () {
                          setState(() {
                            foodInfo.count = 0;
                          });
                        },
                      ),
                      DataCell(
                        Text('${foodInfo.unitPrice * foodInfo.count}円'),
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
                      '${_foods.fold(0, (int a, FoodInfo b) => a + b.count)}個',
                    ), //これGitHub Copilotが書いてくれたんだけど　すげえ
                  ),
                  DataCell(
                    Text(
                      '${amount = _foods.fold(0, (int a, FoodInfo b) => a + b.unitPrice * b.count)}円',
                    ), //これも　プログラマーはもういらないわ
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            iconSize: 50.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayQRContainer(
                    createQRCodeBody: CreateQRCodeBody(
                      merchantPaymentId:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      orderItems: _foods
                          .where((FoodInfo f) => f.count > 0)
                          .map((FoodInfo f) => f.toOrderItem())
                          .toList(),
                      amount: MoneyAmount(amount: amount),
                      requestedAt:
                          (DateTime.now().millisecondsSinceEpoch ~/ 1000),
                    ),
                  ),
                ),
              );
            },
            icon: Image.asset("images/paypay.png"),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("PayPayで支払う"),
        ),
      ],
    );
  }
}
