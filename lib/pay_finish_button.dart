import "package:flutter/material.dart";

class PayFinishButton extends StatelessWidget {
  const PayFinishButton({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
      },
      child: const Text("次のお支払いに進む"),
    );
  }
}
