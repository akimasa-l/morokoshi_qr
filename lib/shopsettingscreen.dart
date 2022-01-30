import "package:flutter/material.dart";
import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "orderscreen.dart";
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "settingscreen.dart";

class Shop {
  const Shop({required this.name});
  final String name;
  Shop.fromMap(Map<String, dynamic> map) : this(name: map['name']!);
  Map<String, String> toMap() => {'name': name};
}

class ShopSettings extends StatelessWidget {
  const ShopSettings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final collection =
        FirebaseFirestore.instance.collection('shops').withConverter<Shop>(
              fromFirestore: (snapshot, _) => Shop.fromMap(snapshot.data()!),
              toFirestore: (shop, _) => shop.toMap(),
            );
    final Stream<QuerySnapshot<Shop>> shopsStream = collection.snapshots();
    return StreamBuilder<QuerySnapshot<Shop>>(
      stream: shopsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("データ消えてるっぽいです。ごめんなさい。");
        }
        final docs = snapshot.data!.docs;
        return Center(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                // FoodSettings(),
                for (final document in docs.asMap().entries)
                  AnimatedShopSetting(
                    child: Text(
                      document.value.data().name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize:
                            Theme.of(context).textTheme.headline4?.fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    index: document.key,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopSettingForm(
                            shop: document.value.data(),
                            reference: document.value.reference,
                          ),
                        ),
                      );
                    },
                  ),
                AnimatedShopSetting(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "新しい店を追加",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize:
                                Theme.of(context).textTheme.headline6?.fontSize,
                          ),
                        ),
                        const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 64,
                        )
                      ],
                    ),
                  ),
                  onPressed: () async {
                    const newShop = Shop(name: "なしお");
                    final newDoc = await collection.add(newShop);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopSettingForm(
                          shop: newShop,
                          reference: newDoc,
                        ),
                      ),
                    );
                    await newDoc
                        .collection("foodInfo")
                        .withConverter<FoodInfo>(
                          fromFirestore: (snapshot, _) =>
                              FoodInfo.fromMap(snapshot.data()!),
                          toFirestore: (foodInfo, _) => foodInfo.toMap(),
                        )
                        .add(AddNewFood.foodInfo);
                  },
                  index: docs.length,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedShopSetting extends StatefulWidget {
  const AnimatedShopSetting({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.index,
  }) : super(key: key);
  final int index;
  final Widget child;
  final void Function() onPressed;
  @override
  State<AnimatedShopSetting> createState() => _AnimatedShopSettingState();
}

class _AnimatedShopSettingState extends State<AnimatedShopSetting> {
  bool animationFlag = false;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(milliseconds: 100 * widget.index),
      () {
        setState(() => animationFlag = !animationFlag);
        timer = Timer.periodic(
          animationDuration,
          (timer) => setState(() => animationFlag = !animationFlag),
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  static const animationDuration = Duration(milliseconds: 800);
  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: animationDuration,
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        top: animationFlag ? 20 : 0,
        bottom: animationFlag ? 0 : 20,
        right: 10,
        left: 10,
      ),
      child: SizedBox(
        height: 200,
        width: 200,
        child: FloatingActionButton(
          heroTag: widget.index,
          onPressed: widget.onPressed,
          child: widget.child,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class ShopSettingForm extends StatefulWidget {
  final DocumentReference<Shop> reference;
  final Shop shop;
  const ShopSettingForm({Key? key, required this.shop, required this.reference})
      : super(key: key);
  @override
  State<ShopSettingForm> createState() => _ShopSettingFormState();
}

class _ShopSettingFormState extends State<ShopSettingForm> {
  @override
  void initState() {
    super.initState();
    // Shop = widget.Shop;
    name = widget.shop.name;
    reference = widget.reference;
  }

  final _formKey = GlobalKey<FormState>();
  // late final Shop Shop;
  late String name;
  late final DocumentReference<Shop> reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                showPlatformDialog(
                  context: context,
                  builder: (context) => PlatformAlertDialog(
                    title: const Text("びっくり!"),
                    content: const Text("本当にこの店を削除しますか？"),
                    actions: <Widget>[
                      PlatformDialogAction(
                        child: const Text("やっぱやめとく..."),
                        onPressed: () => Navigator.pop(context),
                      ),
                      PlatformDialogAction(
                        child: const Text("削除しちゃう!!"),
                        onPressed: () async {
                          final snapshots =
                              await reference.collection("foodInfo").get();
                          for (final snapshot in snapshots.docs) {
                            await snapshot.reference.delete();
                          }
                          await reference.delete();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("削除したよ～～～!!!!"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'What is the name of the shop?',
                      labelText: 'Name *',
                    ),
                    initialValue: name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                      name = value!;
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a name";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    child: const Text("保存する"),
                    onPressed: () async {
                      final state = _formKey.currentState!;
                      if (state.validate()) {
                        state.save();
                        final newShop = Shop(
                          name: name,
                        );
                        await reference.set(newShop);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("保存したよ～～～!!!!"),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
