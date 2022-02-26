import 'package:flutter/material.dart';
import 'package:morokoshi_qr/orderscreen.dart';
import "package:firebase_core/firebase_core.dart";
import "settingscreen.dart" as setting_screen;
import 'firebase_options.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:adaptive_navigation/adaptive_navigation.dart';
import "shopsettingscreen.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "morokoshi_stream_builder.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPrint(Firebase.apps);
  /* if (Firebase.apps.isEmpty) {
    //Unhandled Exception: [core/duplicate-app] A Firebase App named "[DEFAULT]" already existsがおこらないようになる
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app();
  } */
  await Firebase.initializeApp();
  // print(Firebase.app().name);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const _destination = <AdaptiveScaffoldDestination>[
    AdaptiveScaffoldDestination(title: "Pay", icon: Icons.payment),
    AdaptiveScaffoldDestination(title: "Settings", icon: Icons.settings),
    AdaptiveScaffoldDestination(title: "Shops", icon: Icons.business),
  ];
  @override
  void initState() {
    super.initState();
  }
  // int _counter = 0;

  /* void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
    });
  } */
  final Stream<QuerySnapshot<Shop>> _shopsStream = FirebaseFirestore.instance
      .collection('shops')
      .withConverter<Shop>(
        fromFirestore: (snapshot, _) => Shop.fromMap(snapshot.data()!),
        toFirestore: (shop, _) => shop.toMap(),
      )
      .snapshots();
  late CollectionReference<FoodInfo> _foodInfoCollectionReference;
  late int _selectedShopIndex;
  late final SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder(
      future: () async {
        prefs = await SharedPreferences.getInstance();
        _selectedShopIndex = prefs.getInt("selectedShopIndex") ?? 0;
      }(),
      builder: (context, snapshot) {
        return MorokoshiStreamBuilder<Shop>(
          stream: _shopsStream,
          builder: (context, snapshot) {
            if (_selectedShopIndex < 0 ||
                _selectedShopIndex >= snapshot.data!.docs.length) {
              _selectedShopIndex = 0;
            }
            final _selectedShop = snapshot.data!.docs[_selectedShopIndex];
            _foodInfoCollectionReference = _selectedShop.reference
                .collection("foodInfo")
                .withConverter<FoodInfo>(
                  fromFirestore: (snapshot, _) =>
                      FoodInfo.fromMap(snapshot.data()!),
                  toFirestore: (foodInfo, _) => foodInfo.toMap(),
                );
            return AdaptiveNavigationScaffold(
              destinations: _destination,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (selectedIndex) =>
                  setState(() => _selectedIndex = selectedIndex),
              appBar: AdaptiveAppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(
                  widget
                      .title, /* style: const TextStyle(color: Colors.black) */
                ),
                // backgroundColor: Colors.white,
                actions: <Widget>[
                  Center(
                    child: Text(
                      _selectedShop.data().name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.subtitle2?.fontSize,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    initialValue: 0,
                    onSelected: (shopIndex) async {
                      setState(
                        () {
                          // ここいらない気がする？　しないか
                          _selectedShopIndex = shopIndex;
                          final _selectedShop =
                              snapshot.data!.docs[_selectedShopIndex];
                          _foodInfoCollectionReference = _selectedShop.reference
                              .collection("foodInfo")
                              .withConverter<FoodInfo>(
                                fromFirestore: (snapshot, _) =>
                                    FoodInfo.fromMap(snapshot.data()!),
                                toFirestore: (foodInfo, _) => foodInfo.toMap(),
                              );
                        },
                      );
                      await prefs.setInt(
                          "selectedShopIndex", _selectedShopIndex);
                    },
                    itemBuilder: (context) => [
                      for (final shop in snapshot.data!.docs.asMap().entries)
                        PopupMenuItem(
                          value: shop.key,
                          child: Text(shop.value.data().name),
                        )
                    ],
                  )
                ],
              ),
              body: <Widget>[
                CreatePayment(
                  foodInfoCollectionReference: _foodInfoCollectionReference,
                ),
                setting_screen.Settings(
                  foodInfoCollectionReference: _foodInfoCollectionReference,
                ),
                const ShopSettings()
              ][_selectedIndex],
            );
          },
        );
      },
    );
  }
}
