import 'package:flutter_test/flutter_test.dart';
import 'package:morokoshi_qr/paypayclasses.dart';

void main() {
  const paypay = PayPayOPA(
      apiKey: "APIKeyGenerated",
      apiSecret: "APIKeySecretGenerated",
      merchantId: "0");
  expect(paypay.testGenerateAuthHeader(
    nonce: "acd028",
    epoch: "1579843452",
    requestBody:
        "{\"sampleRequestBodyKey1\":\"sampleRequestBodyValue1\",\"sampleRequestBodyKey2\":\"sampleRequestBodyValue2\"}",
    contentType: "application/json;charset=UTF-8;",
    requestUrl: "/v2/codes",
  ),"hmac OPA-Auth:APIKeyGenerated:NW1jKIMnzR7tEhMWtcJcaef+nFVBt7jjAGcVuxHhchc=:acd028:1579843452:1j0FnY4flNp5CtIKa7x9MQ==");
}
