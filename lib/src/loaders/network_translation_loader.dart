import 'package:meta/meta.dart';
import 'package:rest_client/rest_client.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class NetworkTranslationLoader implements TranslationLoader {
  /// Creates a [TranslationLoader] instance that loads from a URL.  The URL
  /// must support returning a JSON key / value map via a `GET` call.
  ///
  /// This optionally takes a map of [headers] that can be used for things like
  /// authorization, language, etc.
  ///
  /// This is a blocking loader and will not resolve the [Future] until the
  /// translations are loaded.  Wrap this in an [AsyncTranslationLoader] to
  /// avoid blocking the [Translator] on [initialize], [load], or [reload].
  NetworkTranslationLoader(
    this.url, {
    this.headers,
  }) : assert(url?.isNotEmpty == true);

  final Map<String, String> headers;
  final String url;

  /// The returned [Future] will wait until the JSON data is loaded and
  /// processed from the network and call and then resolve with resulting
  /// values.
  @override
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  ) async {
    var loader = RestClientTranslationLoader(
      request: Request(
        url: url,
        headers: headers,
      ),
    );

    return loader.load(
      language,
      translator,
    );
  }
}
