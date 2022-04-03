import 'order_screen.dart';

enum PayType {
  cash,
  paypay,
  square,
}

extension PayTypeName on PayType {
  String get name {
    switch (this) {
      case PayType.cash:
        return "cash";
      case PayType.paypay:
        return "PayPay";
      case PayType.square:
        return "Square";
    }
  }
}

extension on String {
  PayType get payType {
    switch (this) {
      case "PayPay":
        return PayType.paypay;
      case "Square":
        return PayType.square;
      default:
        return PayType.cash;
    }
  }
}

class PaymentDetails {
  const PaymentDetails({
    required this.foodCount,
    required this.payType,
  });
  final List<FoodCount> foodCount;
  final PayType payType;
  Map<String, dynamic> toMap() => {
        'paymentDetails': foodCount.map((e) => e.toJson()).toList(),
        'payType': payType.name,
      };
  PaymentDetails.fromMap(Map<String, dynamic> map)
      : assert(map['paymentDetails'] != null),
        assert(map['paymentDetails'] is List),
        assert(map['payType'] != null),
        assert(map['payType'] is String),
        payType = (map['payType'] as String).payType,
        foodCount =
            map['paymentDetails'].map((e) => FoodCount.fromMap(e)).toList();
}
