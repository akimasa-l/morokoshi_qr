import "orderscreen.dart";

class PaymentDetails {
  const PaymentDetails({required this.foodCount});
  final List<FoodCount> foodCount;
  Map<String, dynamic> toJson() => {
        'PaymentDetails': foodCount.map((e) => e.toJson()).toList(),
      };
  PaymentDetails.fromMap(Map<String, dynamic> map)
      :
      assert(map['PaymentDetails'] != null),
      
       foodCount =
            map['PaymentDetails'].map((e) => FoodCount.fromMap(e)).toList();
}
