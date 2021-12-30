import "package:flutter/material.dart";
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
    @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text("aaa"),
        ],
      ),
    );
  }
}
