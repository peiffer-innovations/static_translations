import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:static_translations/static_translations.dart';
import 'package:static_translations_example/src/my_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translator = Translator(
    language: 'en',
    loaders: {
      'en': [
        TranslationLoader.asset('assets/languages/en.json'),
        TranslationLoader.asynchronous(
          TranslationLoader.network(
            'https://raw.githubusercontent.com/peiffer-innovations/static_translations/main/example/assets/languages/en.json',
          ),
        ),
      ],
      'es': [
        TranslationLoader.asset('assets/languages/es.json'),
        TranslationLoader.asynchronous(
          TranslationLoader.network(
            'https://raw.githubusercontent.com/peiffer-innovations/static_translations/main/example/assets/languages/es.json',
          ),
        ),
      ],
    },
  );

  await translator.initialize();

  runApp(MyApp(translator: translator));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
    required this.translator,
  }) : super(key: key);

  final Translator translator;

  @override
  Widget build(BuildContext context) {
    return Provider<Translator>.value(
      value: translator,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(name: 'John Doe'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<StreamSubscription> _subscriptions = [];
  late String _language;
  late Translator _translator;

  @override
  void initState() {
    super.initState();

    _translator = Translator.of(context);
    _subscriptions.add(_translator.translationsStream!.listen((_) {
      if (mounted == true) {
        setState(() {});
      }
    }));

    _language = _translator.language;
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _translator.translate(MyTranslations.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _translator.translate(
                MyTranslations.welcome_message,
                {
                  'name': widget.name,
                },
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButton(
              items: [
                for (var language in _translator.supportedLanguages)
                  DropdownMenuItem(
                    value: language,
                    child: Text(
                      _translator.translate(
                        MyTranslations.fromKey(language),
                      ),
                    ),
                  ),
              ],
              onChanged: (value) => setState(() {
                _language = value?.toString() ?? 'en';
                _translator.setLanguage(_language);
              }),
              value: _language,
            )
          ],
        ),
      ),
    );
  }
}
