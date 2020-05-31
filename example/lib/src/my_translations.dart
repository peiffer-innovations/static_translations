import 'package:meta/meta.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class MyTranslations {
  MyTranslations._();

  static const en = TranslationEntry(
    key: 'en',
    value: 'English',
  );

  static const es = TranslationEntry(
    key: 'es',
    value: 'Spanish',
  );

  static const title = TranslationEntry(
    key: 'title',
    value: 'Static Translations Example',
  );

  static const welcome_message = TranslationEntry(
    key: 'welcome_message',
    value: 'Welcome, {name}',
  );

  static final _all = [
    en,
    es,
    title,
    welcome_message,
  ];

  static TranslationEntry fromKey(String key) {
    TranslationEntry entry;

    for (var e in _all) {
      if (e.key == key) {
        entry = e;
        break;
      }
    }

    if (entry == null) {
      throw new Exception('Unable to find TranslationEntry for key: $key');
    }

    return entry;
  }
}
