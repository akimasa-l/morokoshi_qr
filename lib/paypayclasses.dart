import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MoneyAmount {
  final int amount;
  final String currency;
  const MoneyAmount({required this.amount, this.currency = "JPY"});
  dynamic toJson() => {
        'amount': amount,
        'currency': currency,
      };
}

class PayPayOrderItem {
  final String name, productId, category;
  final int quantity;
  final MoneyAmount unitPrice;
  const PayPayOrderItem({
    required this.name,
    this.productId = "defaultProductId",
    this.category = "ここにcategoryが入るかも",
    required this.quantity,
    required this.unitPrice,
  });
  dynamic toJson() => {
        'name': name,
        'productId': productId,
        'category': category,
        'quantity': quantity,
        'unitPrice': unitPrice /* .toJson() */,
      };
}

class CreateQRCodeBody {
  final String merchantPaymentId,
      orderDescription,
      codeType = "ORDER_QR",
      storeInfo,
      storeId,
      terminalId;
  final MoneyAmount amount;
  final List<PayPayOrderItem> orderItems;
  final dynamic metadata;
  final int requestedAt, authorizationExpiry;
  final bool isAuthorization;
  const CreateQRCodeBody({
    required this.merchantPaymentId,
    this.orderDescription = "ここにOrderDescriptionが入るかも",
    this.storeInfo = "ここにStoreInfoが入るかも",
    this.storeId = "defaultStoreId",
    this.terminalId = "defaultTerminalId",
    required this.amount,
    required this.requestedAt,
    this.orderItems = const [],
    this.metadata,
    this.authorizationExpiry = 60,
    this.isAuthorization = false,
  });
  dynamic toJson() => {
        'merchantPaymentId': merchantPaymentId,
        'orderDescription': orderDescription,
        'codeType': codeType,
        'storeInfo': storeInfo,
        'storeId': storeId,
        'terminalId': terminalId,
        'amount': amount /* .toJson() */,
        'requestedAt': requestedAt,
        'orderItems': orderItems /* .map((e) => e.toJson()).toList() */,
        'metadata': metadata,
        'authorizationExpiry': authorizationExpiry,
        'isAuthorization': isAuthorization,
      };
}

class PayPayOPA {
  final String apiKey, apiSecret, merchantId;
  const PayPayOPA({
    required this.apiKey,
    required this.apiSecret,
    required this.merchantId,
  });
  static const String urlHost = "stg-api.sandbox.paypay.ne.jp";
  Future<String> createQRCode(CreateQRCodeBody body) async {
    const String urlPath = "/v2/codes";
    const String contentType = "application/json;charset=UTF-8";
    final Uri url = Uri(
      scheme: "https",
      host: urlHost,
      path: urlPath,
      queryParameters: {
        "assumeMerchant": merchantId,
      },
    );
    final String nonce = generateNonce();
    final String epoch =
        // (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
        body.requestedAt.toString();
    final String bodyString = json.encode(body);
    final String authHeader = testGenerateAuthHeader(
      nonce: nonce,
      epoch: epoch,
      requestBody: bodyString,
      requestUrl: urlPath,
      contentType: contentType,
    );
    /*   final String signature = generateSignature(
      url: urlPath,
      nonce: nonce,
      timestamp: timestamp,
      body: bodyString,
      /*   apiKey: apiKey, */ /* apiSecret */ /* いらないんだな、それが */
    ); */
/*     final String hash = generateHash(
      requestBody: bodyString,
      contentType: contentType,
    );
    final String hmacData = generateHMACData(
      nonce: nonce,
      hash: hash,
      requestUrl: urlPath,
      epoch: epoch,
      contentType: contentType,
      httpMethod: "POST",
    );*/
    final Map<String, String> headers = {
      "Content-Type": contentType,
      "Authorization": authHeader,
      /*   "X-API-KEY": apiKey,
      "X-API-NONCE": nonce,
      "X-API-TIMESTAMP": timestamp,
      "X-API-SIGNATURE": signature, */
    };
    final response = await http.post(url, headers: headers, body: bodyString);
    // return json.encode(response.request?.headers);
    return response.body;
    /*  if (response.statusCode == 200) {
      return json.decode(response.body)["qr_code"];
    } else {
      throw Exception("Failed to create QR Code");
    } */
  }

  Future<String> getPaymentDetails({required String merchantPaymentId}) async {
    final String urlPath = "/v2/codes/payments/$merchantPaymentId";
    final Uri url = Uri(
      scheme: "https",
      host: urlHost,
      path: urlPath,
      queryParameters: {
        "assumeMerchant": merchantId,
      },
    );
    final String nonce = generateNonce();
    final String epoch =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    // body.requestedAt.toString();
    // final String bodyString = json.encode(body);
    final String authHeader = testGenerateAuthHeader(
      nonce: nonce,
      epoch: epoch,
      // requestBody: bodyString,
      requestUrl: urlPath,
      // contentType: contentType,
    );

    final Map<String, String> headers = {
      // "Content-Type": contentType,
      "Authorization": authHeader,
      /*   "X-API-KEY": apiKey,
      "X-API-NONCE": nonce,
      "X-API-TIMESTAMP": timestamp,
      "X-API-SIGNATURE": signature, */
    };
    final response = await http.post(
      url,
      headers: headers,
      // body: bodyString,
    );
    return response.body;
  }

/*   String generateSignature({
    required String url,
    required String nonce,
    required String timestamp,
    required String body,
    // required String apiKey,
  } /* [String apiSecret] */) {
    final String bodyHash = sha256.convert(utf8.encode(body)).toString();
    final String stringToSign = "$url\n$nonce\n$timestamp\n$bodyHash\n$apiKey";
    final String signature = base64.encode(utf8.encode(stringToSign));
    return signature;
  } */

  static String generateNonce({int length = 8}) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    final randomStr =
        List.generate(length, (_) => charset[random.nextInt(charset.length)])
            .join();
    return randomStr;
  }

  static String generateHash({
    String requestBody = "",
    String contentType = "",
  }) {
    return requestBody.isEmpty && contentType.isEmpty
        ? "empty" // ここもしかしたらなんにもないかも "" 空文字列かも
        : base64Encode(
            md5.convert(utf8.encode(contentType + requestBody)).bytes);
  }

  String generateHMACData({
    required String
        requestUrl, //Only the request URI Example: "/v2/codes/payments/dynamic-qr-test-00002"
    required String httpMethod,
    required String nonce, //Random string
    required String epoch,
    required String contentType,
    required String hash,
  }) {
    final String hmacData =
        "$requestUrl\n$httpMethod\n$nonce\n$epoch\n$contentType\n$hash";
    return base64Encode(Hmac(sha256, utf8.encode(apiSecret))
        .convert(utf8.encode(hmacData))
        .bytes);
  }

  String generateAuthHeader({
    required String hmacData,
    required String nonce,
    required String epoch,
    required String hash,
  }) {
    return "hmac OPA-Auth:$apiKey:$hmacData:$nonce:$epoch:$hash";
  }

  String testGenerateAuthHeader({
    // required String hmacData,
    required String nonce,
    required String epoch,
    String requestBody = "",
    String contentType = "",
    required String requestUrl,
  }) {
    final String hash = generateHash(
      requestBody: requestBody,
      contentType: contentType,
    );
    final String hmacData = generateHMACData(
      nonce: nonce,
      hash: hash,
      requestUrl: requestUrl,
      epoch: epoch,
      contentType: contentType.isEmpty ? "empty" : contentType,
      httpMethod: "POST",
    );
    return generateAuthHeader(
      epoch: epoch,
      hmacData: hmacData,
      nonce: nonce,
      hash: hash,
    );
  }
}
