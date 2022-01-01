import "package:flutter/material.dart";
import 'package:cached_network_image/cached_network_image.dart';

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
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.spaceEvenly,
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const <Widget>[
          FoodInSettings(),
        ],
      ),
    );
  }
}

class FoodInSettings extends StatelessWidget {
  const FoodInSettings({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: Card(
            elevation: 12.0,
            child: InkWell(
              onTap: () {
                // Navigator.pushNamed(context, '/food');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodSettingForm(),
                  ),
                );
              },
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ink.image(
                    image: const CachedNetworkImageProvider(
                        'https://drive.google.com/uc?id=1m8E3fZPj4k35zfCLhAHaV-Nsm8diFJNy'),
                    fit: BoxFit.contain,
                    height: 250,
                  ),
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          'https://drive.google.com/uc?id=1m8E3fZPj4k35zfCLhAHaV-Nsm8diFJNy'),
                    ),
                    title: Text('Hideさん'),
                    subtitle: Text('20円'),
                    trailing: Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FoodSettingForm extends StatefulWidget {
  const FoodSettingForm({Key? key}) : super(key: key);
  @override
  State<FoodSettingForm> createState() => _FoodSettingFormState();
}

class _FoodSettingFormState extends State<FoodSettingForm> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl:
                        'https://drive.google.com/uc?id=1m8E3fZPj4k35zfCLhAHaV-Nsm8diFJNy',
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'What is the name of your food?',
                      labelText: 'Name *',
                    ),
                    initialValue: 'Hideさん',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
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
                    initialValue: '30',
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
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
                    initialValue:
                        'https://drive.google.com/uc?id=1m8E3fZPj4k35zfCLhAHaV-Nsm8diFJNy',
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
