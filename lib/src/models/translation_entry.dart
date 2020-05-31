import 'package:meta/meta.dart';

@immutable
class TranslationEntry {
  /// Constructs the translated value with the [key] that is used as the
  /// identifier for the translated value as well as the translated [value] to
  /// display to the user.
  ///
  /// Values can be parameterized by surrounding the parameter with curley
  /// braces.  Example:
  /// `'Hello, {name}'`.
  ///
  /// Neither the [key] nor the [value] may be [null].
  const TranslationEntry({
    @required this.key,
    @required this.value,
  })  : assert(key != null),
        assert(value != null);

  /// The key, or identifier, for the translation value.  This is the value that
  /// will be used to find the appropriate translation value from the cache.
  /// It is recommended that the key match the variable name to ease
  /// maintenance, but there's no requirement that it follow thta convention.
  final String key;

  /// Translated display value for the string.  Values can be parameterized by
  /// surrounding the parameter with curley braces.  Example:
  /// `'Hello, {name}'`.
  final String value;
}
