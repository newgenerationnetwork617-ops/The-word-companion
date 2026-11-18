import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/bible_package_importer.dart';

String packageJson({
  List<Map<String, Object>> verses = const [
    {'book_id': 1, 'chapter_number': 1, 'verse_number': 1, 'text': 'In the beginning.'},
  ],
}) {
  final content = {'verses': verses};
  final checksum = sha256.convert(utf8.encode(jsonEncode(content))).toString();
  return jsonEncode({
    'manifest': {
      'schema_version': 1,
      'package_type': 'bible_translation',
      'package_id': 'sample-en',
      'display_name': 'Sample English',
      'abbreviation': 'SEN',
      'language_code': 'en',
      'source_name': 'Example publisher',
      'source_url': 'https://example.org/source',
      'licence_name': 'Example open licence',
      'licence_url': 'https://example.org/licence',
      'attribution_text': 'Sample attribution.',
      'package_version': 1,
      'checksum_sha256': checksum,
    },
    'content': content,
  });
}

void main() {
  test('validates package metadata, checksum and verse references', () {
    final result = BiblePackageImporter.validate(packageJson());
    expect(result.id, 'sample-en');
    expect(result.verses, hasLength(1));
    expect(result.verses.single['book_id'], 1);
  });

  test('rejects a modified package checksum', () {
    final source = packageJson().replaceFirst('In the beginning.', 'Changed text.');
    expect(() => BiblePackageImporter.validate(source), throwsFormatException);
  });

  test('rejects references outside the canonical book catalogue', () {
    final source = packageJson(verses: [
      {'book_id': 99, 'chapter_number': 1, 'verse_number': 1, 'text': 'Text'},
    ]);
    expect(() => BiblePackageImporter.validate(source), throwsFormatException);
  });

  test('rejects duplicate verse references', () {
    final source = packageJson(verses: [
      {'book_id': 1, 'chapter_number': 1, 'verse_number': 1, 'text': 'First'},
      {'book_id': 1, 'chapter_number': 1, 'verse_number': 1, 'text': 'Duplicate'},
    ]);
    expect(() => BiblePackageImporter.validate(source), throwsFormatException);
  });

  test('rejects non-English translation packages', () {
    final data = jsonDecode(packageJson()) as Map<String, dynamic>;
    (data['manifest'] as Map<String, dynamic>)['language_code'] = 'fr';
    expect(() => BiblePackageImporter.validate(jsonEncode(data)), throwsFormatException);
  });

  test('rejects unsupported package schema versions', () {
    final data = jsonDecode(packageJson()) as Map<String, dynamic>;
    (data['manifest'] as Map<String, dynamic>)['schema_version'] = 2;
    expect(() => BiblePackageImporter.validate(jsonEncode(data)), throwsFormatException);
  });
}
