import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'bible_catalog.dart';
import 'local_database.dart';

class ValidatedBiblePackage {
  const ValidatedBiblePackage({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.languageCode,
    required this.sourceName,
    required this.sourceUrl,
    required this.licenceName,
    required this.licenceUrl,
    required this.attribution,
    required this.packageVersion,
    required this.checksum,
    required this.verses,
  });

  final String id;
  final String name;
  final String abbreviation;
  final String languageCode;
  final String sourceName;
  final String sourceUrl;
  final String licenceName;
  final String licenceUrl;
  final String attribution;
  final int packageVersion;
  final String checksum;
  final List<Map<String, Object>> verses;
}

class BiblePackageImporter {
  BiblePackageImporter({LocalDatabase? localDatabase})
      : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  /// Package format: { "manifest": {...}, "content": { "verses": [...] } }.
  /// The manifest checksum is SHA-256 of UTF-8 jsonEncode(content).
  static ValidatedBiblePackage validate(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Package root must be a JSON object.');
    }
    final manifest = decoded['manifest'];
    final content = decoded['content'];
    if (manifest is! Map<String, dynamic> ||
        content is! Map<String, dynamic>) {
      throw const FormatException('Package manifest or content is missing.');
    }

    String requiredText(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Manifest field "$key" is required.');
      }
      return value.trim();
    }

    final schemaVersion = manifest['schema_version'];
    if (schemaVersion != 1) {
      throw const FormatException('Unsupported package schema version.');
    }
    if (requiredText(manifest, 'package_type') != 'bible_translation') {
      throw const FormatException('This installer accepts Bible translations only.');
    }
    final id = requiredText(manifest, 'package_id');
    final name = requiredText(manifest, 'display_name');
    final abbreviation = requiredText(manifest, 'abbreviation');
    final language = requiredText(manifest, 'language_code');
    if (!language.toLowerCase().startsWith('en')) {
      throw const FormatException('Only English Bible translation packages are supported.');
    }
    final sourceName = requiredText(manifest, 'source_name');
    final sourceUrl = requiredText(manifest, 'source_url');
    final licenceName = requiredText(manifest, 'licence_name');
    final licenceUrl = requiredText(manifest, 'licence_url');
    final attribution = requiredText(manifest, 'attribution_text');
    final packageVersion = manifest['package_version'];
    if (packageVersion is! int || packageVersion < 1) {
      throw const FormatException('package_version must be a positive integer.');
    }
    final suppliedChecksum = requiredText(manifest, 'checksum_sha256').toLowerCase();
    final calculatedChecksum = sha256.convert(utf8.encode(jsonEncode(content))).toString();
    if (suppliedChecksum != calculatedChecksum) {
      throw const FormatException('Package checksum does not match its content.');
    }

    final rawVerses = content['verses'];
    if (rawVerses is! List || rawVerses.isEmpty) {
      throw const FormatException('The package contains no Bible verses.');
    }
    final knownBooks = {for (final book in bibleBooks) book.id: book};
    final seen = <String>{};
    final verses = <Map<String, Object>>[];
    for (final item in rawVerses) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Each verse must be a JSON object.');
      }
      final bookId = item['book_id'];
      final chapter = item['chapter_number'];
      final verseNumber = item['verse_number'];
      final text = item['text'];
      if (bookId is! int || chapter is! int || verseNumber is! int ||
          text is! String || text.trim().isEmpty) {
        throw const FormatException('A verse has missing or invalid fields.');
      }
      final book = knownBooks[bookId];
      if (book == null || chapter < 1 || chapter > book.chapters || verseNumber < 1) {
        throw const FormatException('A verse contains an invalid Scripture reference.');
      }
      final key = '$bookId:$chapter:$verseNumber';
      if (!seen.add(key)) {
        throw FormatException('Duplicate verse reference: $key.');
      }
      verses.add({
        'book_id': bookId,
        'chapter_number': chapter,
        'verse_number': verseNumber,
        'text': text.trim(),
      });
    }

    return ValidatedBiblePackage(
      id: id,
      name: name,
      abbreviation: abbreviation,
      languageCode: language,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      licenceName: licenceName,
      licenceUrl: licenceUrl,
      attribution: attribution,
      packageVersion: packageVersion,
      checksum: suppliedChecksum,
      verses: List.unmodifiable(verses),
    );
  }

  Future<void> install(String source) async {
    final package = validate(source);
    final db = await _localDatabase.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'bible_versions',
        columns: ['id'],
        where: 'id = ? OR abbreviation = ?',
        whereArgs: [package.id, package.abbreviation],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw StateError('This Bible translation is already installed.');
      }

      await txn.insert('bible_versions', {
        'id': package.id,
        'name': package.name,
        'abbreviation': package.abbreviation,
        'language_code': package.languageCode,
        'source_name': package.sourceName,
        'licence_name': package.licenceName,
        'licence_url': package.licenceUrl,
        'installed_at': DateTime.now().toUtc().toIso8601String(),
        'content_version': package.packageVersion,
      });

      final batch = txn.batch();
      for (final verse in package.verses) {
        batch.insert('verses', {
          ...verse,
          'version_id': package.id,
        });
        batch.insert('verse_search', {
          ...verse,
          'version_id': package.id,
        });
      }
      await batch.commit(noResult: true);

      await txn.insert('installed_content_packages', {
        'package_id': package.id,
        'package_type': 'bible_translation',
        'package_version': package.packageVersion,
        'display_name': package.name,
        'source_name': package.sourceName,
        'licence_name': package.licenceName,
        'installed_at': DateTime.now().toUtc().toIso8601String(),
        'checksum_sha256': package.checksum,
      });
      await txn.insert('app_metadata', {
        'key': 'package_attribution_${package.id}',
        'value': package.attribution,
      });
    });
  }
}
