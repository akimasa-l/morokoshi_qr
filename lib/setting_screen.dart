import "package:flutter/material.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'order_screen.dart';
import "morokoshi_cached_network_image.dart";
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class Settings extends StatelessWidget {
  const Settings({Key? key, required this.foodInfoCollectionReference})
      : super(key: key);
  final CollectionReference<FoodInfo> foodInfoCollectionReference;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<FoodInfo>>(
      stream: foodInfoCollectionReference.snapshots(),
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
                for (final document in snapshot.data!.docs)
                  FoodSettings(
                    document: document.reference,
                    foodInfo: document.data(),
                  ),
                AddNewFood(
                  foodInfoCollectionReference: foodInfoCollectionReference,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FoodSettingsBase extends StatelessWidget {
  final void Function()? onTap;
  final Widget? child;
  const FoodSettingsBase({Key? key, this.onTap, this.child}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 12.0,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

class AddNewFood extends StatelessWidget {
  const AddNewFood({Key? key, required this.foodInfoCollectionReference})
      : super(key: key);
  final CollectionReference<FoodInfo> foodInfoCollectionReference;
  static const foodInfo = FoodInfo(
    imageUrl:
        "https://drive.google.com/uc?id=1m8E3fZPj4k35zfCLhAHaV-Nsm8diFJNy",
    name: "Hideさん",
    unitPrice: 30,
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FoodSettingsBase(
      onTap: () async {
        final reference = await foodInfoCollectionReference.add(foodInfo);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodSettingForm(
              foodInfo: foodInfo,
              reference: reference,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "新しい商品を追加する",
              style: Theme.of(context).textTheme.headline6,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.add,
                size: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodSettings extends StatelessWidget {
  final DocumentReference<FoodInfo> document;
  final FoodInfo foodInfo;
  const FoodSettings({
    Key? key,
    required this.document,
    required this.foodInfo,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FoodSettingsBase(
      onTap: () {
        // Navigator.pushNamed(context, '/food');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodSettingForm(
              foodInfo: foodInfo,
              reference: document,
            ),
          ),
        );
      },
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Ink.image(
            image: CachedNetworkImageProvider(foodInfo.imageUrl),
            fit: BoxFit.contain,
            height: 250,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(foodInfo.imageUrl),
            ),
            title: Text(foodInfo.name),
            subtitle: Text('${foodInfo.unitPrice}円'),
            trailing: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}

class FoodSettingForm extends StatefulWidget {
  final DocumentReference<FoodInfo> reference;
  final FoodInfo foodInfo;
  const FoodSettingForm(
      {Key? key, required this.foodInfo, required this.reference})
      : super(key: key);
  @override
  State<FoodSettingForm> createState() => _FoodSettingFormState();
}

class _FoodSettingFormState extends State<FoodSettingForm> {
  @override
  void initState() {
    super.initState();
    // foodInfo = widget.foodInfo;
    imageUrl = widget.foodInfo.imageUrl;
    name = widget.foodInfo.name;
    unitPrice = widget.foodInfo.unitPrice;
    reference = widget.reference;
  }

  final _formKey = GlobalKey<FormState>();
  // late final FoodInfo foodInfo;
  late String imageUrl, name;
  late int unitPrice;
  late final DocumentReference<FoodInfo> reference;

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
                  content: const Text("本当に削除しますか？"),
                  actions: <Widget>[
                    PlatformDialogAction(
                      child: const Text("やっぱやめとく..."),
                      onPressed: () => Navigator.pop(context),
                    ),
                    PlatformDialogAction(
                      child: const Text("削除しちゃう!!"),
                      onPressed: () async {
                        await reference.delete();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
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
                  MorokoshiCachedNetworkImage(
                    imageUrl: imageUrl,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'What is the name of your food?',
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
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.price_change),
                      hintText: 'How much is it?',
                      labelText: 'Price *',
                      suffix: Text('円'),
                    ),
                    initialValue: unitPrice.toString(),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                      unitPrice = int.parse(value!);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a price";
                      }
                      final price = int.tryParse(value);
                      if (price == null) {
                        return 'Please enter a valid number';
                      }
                      if (price <= 0) {
                        return 'Please enter a number greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.image),
                      hintText: 'What is the URL of the image of the food?',
                      labelText: 'URL',
                    ),
                    initialValue: imageUrl,
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.

                      setState(() {
                        // debugPrint("setState");
                        imageUrl = value!;
                      });
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a URL";
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
                        final newFoodInfo = FoodInfo(
                          name: name,
                          unitPrice: unitPrice,
                          imageUrl: imageUrl,
                        );
                        await reference.set(newFoodInfo);
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
