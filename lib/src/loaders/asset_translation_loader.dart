import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:static_translations/static_translations.dart';

@immutable
class AssetTranslationLoader implements TranslationLoader {
  /// Creates a [TranslationLoader] instance that loads from local asset files.
  /// When loading from a package, you must pass the name of the package via the
  /// [package] optional parameter.  The asset must be a JSON key / value map.
  ///
  /// This loader is technically blocking, but extremely fast assuming the JSON
  /// asset is not crazy massive.  For most use cases, this can be treated as if
  /// it is a non-blocking loader.
  AssetTranslationLoader(
    this.asset, {
    this.package,
  });

  final String asset;
  final String? package;

  /// The returned [Future] will wait until the JSON asset is loaded and
  /// processed and then resolve with resulting values.
  @override
  Future<Map<String, String>> load(
    String language,
    Translator translator,
  ) async {
    var data = await rootBundle.loadString(
      package?.isNotEmpty == true ? 'packages/$package/$asset' : asset,
    );

    var result = <String, String>{};
    var converted = json.decode(data);

    converted?.forEach((key, value) => result[key] = value.toString());
    return result;
  }
}
