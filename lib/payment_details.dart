import 'order_screen.dart';

class PaymentDetails {
  const PaymentDetails({required this.foodCount});
  final List<FoodCount> foodCount;
  Map<String, dynamic> toMap() => {
        'PaymentDetails': foodCount.map((e) => e.toJson()).toList(),
      };
  PaymentDetails.fromMap(Map<String, dynamic> map)
      :
      assert(map['PaymentDetails'] != null),
      assert(map['PaymentDetails'] is List),
       foodCount =
            map['PaymentDetails'].map((e) => FoodCount.fromMap(e)).toList();
}
