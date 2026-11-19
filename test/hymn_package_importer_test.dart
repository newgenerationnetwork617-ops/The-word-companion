import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:the_word_companion/data/hymn_package_importer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> makePackage({String language = 'en', String type = 'hymn_collection'}) {
    final content = {'hymns': [{'title': 'Sample Hymn', 'lyrics': 'First verse\nSecond verse', 'hymn_number': '1', 'first_line': 'First verse'}]};
    final checksum = sha256.convert(utf8.encode(jsonEncode(content))).toString();
    return {
      'manifest': {
        'schema_version': 1, 'package_type': type, 'package_id': 'sample-hymns',
        'display_name': 'Sample English Hymns', 'language_code': language,
        'source_name': 'Sample source', 'source_url': 'https://example.org/source',
        'licence_name': 'Public domain', 'licence_url': 'https://example.org/licence',
        'attribution_text': 'Sample attribution', 'package_version': 1,
        'checksum_sha256': checksum,
      },
      'content': content,
    };
  }

  test('bundled hymn collections are valid offline packages', () async {
    for (final asset in [
      'assets/hymns/twc-original-praise.json',
      'assets/hymns/twc-scripture-songs.json',
    ]) {
      final source = await rootBundle.loadString(asset);
      final package = HymnPackageImporter.validate(source);
      expect(package.languageCode, 'en');
      expect(package.hymns, hasLength(4));
    }
  });

  test('valid English hymn package is accepted', () {
    final result = HymnPackageImporter.validate(jsonEncode(makePackage()));
    expect(result.name, 'Sample English Hymns');
    expect(result.hymns, hasLength(1));
  });

  test('non-English hymn packages are rejected', () {
    expect(() => HymnPackageImporter.validate(jsonEncode(makePackage(language: 'fr'))), throwsFormatException);
  });

  test('incorrect checksum is rejected', () {
    final package = makePackage();
    package['manifest']['checksum_sha256'] = '0' * 64;
    expect(() => HymnPackageImporter.validate(jsonEncode(package)), throwsFormatException);
  });

  test('wrong package type is rejected', () {
    expect(() => HymnPackageImporter.validate(jsonEncode(makePackage(type: 'bible_translation'))), throwsFormatException);
  });
}
