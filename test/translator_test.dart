import 'package:flutter_test/flutter_test.dart';
import 'package:static_translations/static_translations.dart';

void main() {
  test('supported languages', () {
    var translator = Translator(language: 'en', loaders: {});
    expect(translator.supportedLanguages.toString(), [].toString());

    translator = Translator(language: 'en', loaders: {
      'en': [],
    });
    expect(translator.supportedLanguages.toString(), ['en'].toString());

    translator = Translator(language: 'en', loaders: {
      'en': [],
      'es': [],
    });
    expect(translator.supportedLanguages.toString(), ['en', 'es'].toString());
  });
}
