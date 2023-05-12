<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**ARCHIVED**: This is no longer maintained as the built in [i18n](https://pub.dev/packages/i18n) packages have become a far better superior solution.

**Table of Contents**

- [static_translations](#static_translations)
  - [Using the library](#using-the-library)
  - [Creating Static References](#creating-static-references)
  - [Using Loaders](#using-loaders)
  - [Binding to Provider](#binding-to-provider)
  - [Using Translation Values](#using-translation-values)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# static_translations

A Flutter library to provide a consistent and reliable way to reference 
translation values in a typesafe way.


## Using the library

Add the repo to your Flutter `pubspec.yaml` file.

```
dependencies:
  static_translations: <<version>> 
```

Then run...
```
flutter packages get
```



## Creating Static References

The library utilizes the `TranslationEntry` class to ensure all dynamic strings
exist in a code-safe way.  To simplify maintenance and standardize things in a
way teams of developers can easily follow, it is recommended that the variable
name and the key of the `TranslationEntry` be all lower case separated with
underscores and the same value.

The `TranslationEntry` must provide a default translation for when the
`Translator` is unable to load replacement values.  This ensures the application
can function with a default language no matter what else may go wrong.

Example:
```dart
import 'package:meta/meta.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class MyTranslations {
  MyTranslations._();

  static const button_submit = TranslationEntry(
    key: 'button_submit',
    value: 'Submit',
  );

  static const welcome_message = TranslationEntry(
    key: 'welcome_message',
    value: 'Welcome, {name}',
  );

  static const what_is_your_name = TranslationEntry(
    key: 'what_is_your_name',
    value: 'What is your name?',
  );
}
```


## Using Loaders

The `TranslationLoader` class provides many convenience factory constructors for
loading translations values by different means.  These loaders may be blocking
or non-blocking.

A blocking loader waits to resolve it's `Future` until it has completed loading
and processing the translations.  A non-blocking loader will resolve the 
`Future` immediately, and apply the translations to the cache when they are
available.

It is recommended that applications utilize non-blocking loaders for app
initialization and then optionally use blocking loaders to load franslations
unrelated to app startup.

Example:
```dart
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var translator = Translator(
    loaders: {
      'en': [
        TranslationLoader.asset('assets/languages/$language.json'),
        TranslationLoader.asynchronous(
          TranslationLoader.network(
            'https://raw.githubusercontent.com/peiffer-innovations/static_translations/main/example/assets/languages/$language.json',
          ),
        ),
      ],
    },
  );

  await translator.initialize();

  runApp(MyApp(translator: translator));
}
```


## Binding to Provider

While not required, the `Translator` class is designed to work with the 
[provider](https://pub.dev/packages/provider) package to be used as a type of
dependency injection.

```dart
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class MyApp extends StatefulWidget {
  MyApp({
    Key key,
    @required this.translator,
  })  : assert(translator != null),
        super(key: key);

  final Translator translator;

  @override
  Widget build(BuildContext context) {
    return Provider<Translator>.value(
      value: translator,
      child: MaterialApp(
        ...
      ),
    );
  }
}
```


## Using Translation Values

Assuming you bound the `Translator` to the widget tree using `Provider` like the
above example, getting translation values is quite simple.  Simply retrieve the
`Translator` from the `Provider`, and call the `translate` function.

If no loader has set a value for a given `TranslationEntry`'s `key` then the
default value for the `TranslationEntry` will be used.  Effectively this really
means that only translation files need to be loaded for the non-default
languages and an empty array can be passed to the `Translator` for the default
language's loaders.

Example:
```dart
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class HelloWidget extends StatelessWidget {
  MyWidget({
    Key key,
    this.name,
  })  : assert(name != null),
        super(key: key);

  final String name;

  Widget build(BuildContext context) {
    var translator = Translator.of(context);

    return Text(
      translator.translate(
        MyTranslations.welcome_message,
        {
          'name': name,
        },
      ),
    );
  }
}
```
