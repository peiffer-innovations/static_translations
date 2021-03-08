import 'package:meta/meta.dart';
import 'package:rest_client/rest_client.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class RestClientTranslationLoader implements TranslationLoader {
  /// A more powerful version of the simple [network] factory.  Tihs gives full
  /// control over the way the network call is executed.  This stillrequires the
  /// response from the network call result in a JSON key / value map.
  ///
  /// This is a blocking loader and will not resolve the [Future] until the
  /// translations are loaded.  Wrap this in an [AsyncTranslationLoader] to
  /// avoid blocking the [Translator] on [initialize], [load], or [reload].
  RestClientTranslationLoader({
    this.authorizer,
    Client? client,
    this.reporter,
    required this.request,
    this.retryCount = 0,
    this.retryDelay = const Duration(seconds: 1),
    this.retryDelayStrategy,
    this.timeout,
  }) : client = client ?? Client();

  final Authorizer? authorizer;
  final Client client;
  final Reporter? reporter;
  final Request request;
  final int retryCount;
  final Duration retryDelay;
  final DelayStrategy? retryDelayStrategy;
  final Duration? timeout;

  /// The returned [Future] will wait until the JSON data is loaded and
  /// processed from the network and call and then resolve with resulting
  /// values.
  @override
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  ) async {
    var response = await client.execute(
      authorizer: authorizer,
      reporter: reporter,
      request: request,
      retryCount: retryCount,
      retryDelay: retryDelay,
      retryDelayStrategy: retryDelayStrategy,
      timeout: timeout,
    );

    var result = <String, String>{};
    var converted = response.body;

    converted?.forEach((key, value) => result[key] = value.toString());
    return result;
  }
}
