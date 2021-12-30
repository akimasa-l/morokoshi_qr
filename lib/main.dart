import 'package:flutter/material.dart';
import 'package:morokoshi_qr/orderscreen.dart';
// import "firebase_options.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:adaptive_navigation/adaptive_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /* print(Firebase.apps);
  if (Firebase.apps.isEmpty) {
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
  final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream =
      FirebaseFirestore.instance.collection('foodInfo').snapshots();
  int _selectedIndex = 0;
  static const  _destination = <AdaptiveScaffoldDestination>[
    AdaptiveScaffoldDestination(title: "Home", icon: Icons.home),
    AdaptiveScaffoldDestination(title: "Pay", icon: Icons.payment),
  ];
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return AdaptiveNavigationScaffold(
      destinations: _destination,
      selectedIndex: _selectedIndex,
      onDestinationSelected:(int selectedIndex)=>setState(()=>_selectedIndex=selectedIndex),
      appBar: AdaptiveAppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /*  const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ), */
              // const DisplayQRContainer(),
              /* FoodWidgets(
                foods: [
                  FoodInfo(
                    unitPrice: 30,
                    name: "Hideさん",
                    imagePath: "images/hide4063.png",
                  ),
                  FoodInfo(
                    unitPrice: 20,
                    name: "Hideさん2",
                    imagePath: "images/hide4063.png",
                  ),
                  FoodInfo(
                    unitPrice: 15,
                    name: "Hideさん3",
                    imagePath: "images/hide4063.png",
                  ),
                  FoodInfo(
                    unitPrice: 3,
                    name: "Hideさん4",
                    imagePath: "images/hide4063.png",
                  ),
                  FoodInfo(
                    unitPrice: 2,
                    name: "Hideさん5",
                    imagePath: "images/hide4063.png",
                  ),
                  FoodInfo.fromMap({
                    "unitPrice": 30,
                    "name": "Hideさん",
                    "imagePath": "images/hide4063.png",
                  }),
                ],
              ), */
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _usersStream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    return FoodWidgets(
                      foods: <FoodInfo>[
                        for (final document in snapshot.data!.docs)
                          FoodInfo.fromMap(
                              document.data() as Map<String, dynamic>),
                      ],
                    );
                    /* return Column(children: <Widget>[
                      for (final document in snapshot.data!.docs)
                        Text(document.data().toString()),
                    ]); */
                  }),
            ],
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),  */ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
