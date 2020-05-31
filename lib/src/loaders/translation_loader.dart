import 'package:meta/meta.dart';
import 'package:rest_client/rest_client.dart';
import 'package:static_translations/static_translations.dart';

abstract class TranslationLoader {
  /// Creates a [TranslationLoader] instance that loads from local asset files.
  /// When loading from a package, you must pass the name of the package via the
  /// [package] optional parameter.  The asset must be a JSON key / value map.
  ///
  /// This loader is technically blocking, but extremely fast assuming the JSON
  /// asset is not crazy massive.  For most use cases, this can be treated as if
  /// it is a non-blocking loader.
  ///
  /// This is a convenience factory constructor and is ultimately a synonym for
  /// constructing an [AssetTranslationLoader] directly.
  factory TranslationLoader.asset(
    String asset, {
    String package,
  }) =>
      AssetTranslationLoader(
        asset,
        package: package,
      );

  /// Creates a non-blocking [TranslationLoader] instance that that will load
  /// the translations asynchronously and apply them back to the [Translator]
  /// when complete.
  ///
  /// This is a convenience factory constructor and is ultimately a synonym for
  /// constructing an [AsyncTranslationLoader] directly.
  factory TranslationLoader.asynchronous(
    TranslationLoader loader,
  ) =>
      AsyncTranslationLoader(loader);

  /// Creates a [TranslationLoader] instance with the given [values] to utilize.
  ///
  /// This is effectively non-blocking because it does not need to wait for any
  /// external data.
  ///
  /// This is a convenience factory constructor and is ultimately a synonym for
  /// constructing an [MemoryTranslationLoader] directly.
  factory TranslationLoader.memory(Map<String, String> values) =>
      MemoryTranslationLoader(values);

  /// Creates a [TranslationLoader] instance that loads from a URL.  The URL
  /// must support returning a JSON key / value map via a `GET` call.
  ///
  /// This optionally takes a map of [headers] that can be used for things like
  /// authorization, language, etc.
  ///
  /// This is a blocking loader and will not resolve the [Future] until the
  /// translations are loaded.  Wrap this in an [AsyncTranslationLoader] to
  /// avoid blocking the [Translator] on [initialize], [load], or [reload].
  ///
  /// This is a convenience factory constructor and is ultimately a synonym for
  /// constructing an [NetworkTranslationLoader] directly.
  factory TranslationLoader.network(
    String url, {
    Map<String, String> headers,
  }) =>
      NetworkTranslationLoader(
        url,
        headers: headers,
      );

  /// A more powerful version of the simple [network] factory.  Tihs gives full
  /// control over the way the network call is executed.  This stillrequires the
  /// response from the network call result in a JSON key / value map.
  ///
  /// This is a blocking loader and will not resolve the [Future] until the
  /// translations are loaded.  Wrap this in an [AsyncTranslationLoader] to
  /// avoid blocking the [Translator] on [initialize], [load], or [reload].
  ///
  /// This is a convenience factory constructor and is ultimately a synonym for
  /// constructing an [RestClientTranslationLoader] directly.
  factory TranslationLoader.restClient({
    Authorizer authorizer,
    Client client,
    Reporter reporter,
    @required Request request,
    int retryCount = 0,
    Duration retryDelay = const Duration(seconds: 1),
    DelayStrategy retryDelayStrategy,
    Duration timeout,
  }) =>
      RestClientTranslationLoader(
        authorizer: authorizer,
        client: client,
        reporter: reporter,
        request: request,
        retryCount: retryCount,
        retryDelay: retryDelay,
        retryDelayStrategy: retryDelayStrategy,
        timeout: timeout,
      );

  /// Interface all [TranslationLoader] instances must implement.  The language
  /// to load is passed in but may or may not actually be used by the loader.
  /// The built in loaders to not make use of this value to actually perform
  /// the loading function.  Instead, they only use it to ensure that when
  /// translations are loaded asynchronously, the language on the [Translator]
  /// is still the one the loader was attempting to load.
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  );
}
