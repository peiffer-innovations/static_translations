import 'package:static_translations/static_translations.dart';

class MemoryTranslationLoader implements TranslationLoader {
  /// Creates a [TranslationLoader] instance with the given [values] to utilize.
  ///
  /// This is  non-blocking as it does not need to wait for any external data.
  MemoryTranslationLoader(
    this.values,
  );

  final Map<String, String> values;

  /// The returned [Future] will immediately resolve with the [values].
  @override
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  ) async =>
      values;
}
