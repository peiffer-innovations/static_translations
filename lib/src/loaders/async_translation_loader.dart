import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class AsyncTranslationLoader implements TranslationLoader {
  /// Creates a non-blocking [TranslationLoader] instance that that will load
  /// the translations asynchronously and apply them back to the [Translator]
  /// when complete.
  AsyncTranslationLoader(
    this.loader,
  ) : assert(loader != null);

  final TranslationLoader loader;

  /// This will call the [loader] and then immediately resolve the [Future] with
  /// [null].  Once the associated [loader]'s [Future] resolves, this will then
  /// [apply] the values to the [translator].
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  ) async {
    var future = loader.load(
      language,
      translator,
    );
    future
        .then(
      (value) => translator.apply(language, value),
    )
        .catchError(
      (e, stack) {
        if (e is FlutterErrorDetails) {
          FlutterError.reportError(e);
        } else {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: e,
              stack: stack,
            ),
          );
        }
      },
    );

    return null;
  }
}
