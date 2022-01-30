import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class UnloadedWidget extends StatelessWidget {
  const UnloadedWidget(this.title, {Key? key}) : super(key: key);
  final String title;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title),
      ),
    );
  }
}

class MorokoshiStreamBuilder<T> extends StatelessWidget {
  const MorokoshiStreamBuilder(
      {Key? key, required this.stream, required this.builder})
      : super(key: key);
  final Stream<QuerySnapshot<T>> stream;
  final Widget Function(BuildContext, AsyncSnapshot<QuerySnapshot<T>>) builder;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return UnloadedWidget('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const UnloadedWidget("Loading");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const UnloadedWidget("データ消えてるっぽいです。ごめんなさい。");
        }
        return builder(context, snapshot);
      },
    );
  }
}
