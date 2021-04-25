import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:static_translations/static_translations.dart';

/// Translator to return dynamic strings loaded through various loaders.
class Translator {
  /// Constructs the [Translator] with mapping of supported languages codes to
  /// the respective list of [TranslationLoader] instances to laod the values
  /// for each supported language.
  ///
  /// Upon calling [initialize], the list of loaders for the passed in
  /// [language] will be used.
  Translator({
    required String language,
    required Map<String, List<TranslationLoader>> loaders,
  })   : _language = language,
        _loaders = loaders;

  final Map<String, List<TranslationLoader>> _loaders;
  final Map<String, String> _translations = {};

  String _language;
  StreamController<void>? _translationsStreamController =
      StreamController<void>.broadcast();

  /// Finds the [Translator] that was added to the widget tree via [Provider].
  /// If no [Translator] is found on the widget tree then this will return a
  /// default, empty, instance.
  static Translator of([BuildContext? context]) {
    Translator? result;
    if (context != null) {
      try {
        result = Provider.of<Translator>(
          context,
          listen: false,
        );
      } catch (e) {
        // ignore and use a default instance
      }
    }

    return result ??
        Translator(
          language: 'default',
          loaders: {},
        );
  }

  /// Returns the currently set language.
  String get language => _language;

  /// Returns the list of language codes this instance has been set up to
  /// support.
  List<String> get supportedLanguages => _loaders.keys.toList();

  /// Returns a [Stream] that can be listened to when the translation values
  /// change.  Applications may choose to listen to this to be notified when
  /// lazy loaded translations are applied so the UI can be updated
  /// appropriately.
  Stream<void>? get translationsStream => _translationsStreamController?.stream;

  /// Initializes the [Translator] by calling, and `await`-ing all loaders for
  /// the this was constructed with.
  ///
  /// The returned [Future] will not resolve until all Futures from the loaders
  /// all resolve.
  ///
  /// This should only be called once per instance.
  Future<void> initialize() async {
    await _load(_loaders[_language]);
  }

  /// Disposes the [Translator] and releases all associated resources.  Once
  /// called, future calls to this instance will result in errors.
  void dispose() {
    _translationsStreamController?.close();
    _translationsStreamController = null;
  }

  /// Applies the given set of translated strings to the translator.  This will
  /// no-op if the given [language] is not the currently set language.
  ///
  /// This is meant to provide support for lazy loading translations.
  void apply(
    String language,
    Map<String, String>? values,
  ) {
    if (language == _language) {
      _translations.addAll(values ?? {});
      _translationsStreamController?.add(null);
    }
  }

  /// Sets the [language] to the given value.  While the language should be one
  /// in the [supportedLanguages] list, that is not actually a requirement.
  /// Setting the [language] to one that is not part of the [supportedLanguages]
  /// will result in the cached values being cleared and default strings being
  /// used until / unless the application applies the new translation values via
  /// the [apply] function.
  Future<void> setLanguage(String language) {
    _language = language;
    _translations.clear();
    _translationsStreamController?.add(null);
    return _load(_loaders[language]);
  }

  /// Translates the given entry.  Dynamic args must be surrounded in curley
  /// braces.
  ///
  /// ```dart
  /// var result = translator.translate(
  ///   TranslationEntry(
  ///     key: 'my_key',
  ///     value: 'Welcome: {firstName} {lastName}'
  ///   ),
  ///   {
  ///     'firstName': 'John',
  ///     'lastName': 'Doe',
  ///   },
  /// );
  ///
  /// print(result); // "Welcome: John Doe"
  /// ```
  String translate(
    TranslationEntry entry, [
    Map<String, dynamic>? args,
  ]) {
    var translated = _translations[entry.key] ?? entry.value;

    args?.forEach((key, value) {
      translated = translated.replaceAll('{$key}', '$value');
    });

    return translated;
  }

  /// Loads translations from all the given loaders and returns when all have
  /// completed.
  Future<void> _load(List<TranslationLoader>? loaders) async {
    var futures = loaders?.map((e) => e.load(_language, this));

    if (futures != null) {
      for (var future in futures) {
        // ignore: unawaited_futures
        future.then((values) => apply(_language, values));
      }

      await Future.wait(futures);
    }
  }
}
