import 'package:morokoshi_qr/paypayclasses.dart';

void main() {
  const paypay = PayPayOPA(
      apiKey: "APIKeyGenerated",
      apiSecret: "APIKeySecretGenerated",
      merchantId: "0");
  print(paypay.testGenerateAuthHeader(
    nonce: "acd028",
    epoch: "1579843452",
    requestBody:
        "{\"sampleRequestBodyKey1\":\"sampleRequestBodyValue1\",\"sampleRequestBodyKey2\":\"sampleRequestBodyValue2\"}",
    contentType: "application/json;charset=UTF-8;",
    requestUrl: "/v2/codes",
  ));
}
