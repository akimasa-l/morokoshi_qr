import "package:flutter/material.dart";

class MorokoshiFutureBuilder<T> extends StatelessWidget {
  const MorokoshiFutureBuilder({
    Key? key,
    required this.future,
    required this.builder,
  }) : super(key: key);
  final Future<T> future;
  final AsyncWidgetBuilder<T> builder;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("エラーが起きました: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return builder(context, snapshot);
        });
  }
}
