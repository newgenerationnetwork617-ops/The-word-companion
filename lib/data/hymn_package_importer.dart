import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'local_database.dart';

class ValidatedHymnPackage {
  const ValidatedHymnPackage({
    required this.id, required this.name, required this.languageCode,
    required this.sourceName, required this.sourceUrl, required this.licenceName,
    required this.licenceUrl, required this.attribution, required this.packageVersion,
    required this.checksum, required this.hymns,
  });
  final String id, name, languageCode, sourceName, sourceUrl, licenceName, licenceUrl, attribution, checksum;
  final int packageVersion;
  final List<Map<String, Object>> hymns;
}

class HymnPackageImporter {
  HymnPackageImporter({LocalDatabase? localDatabase}) : _localDatabase = localDatabase ?? LocalDatabase.instance;
  final LocalDatabase _localDatabase;

  static ValidatedHymnPackage validate(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Package root must be a JSON object.');
    final manifest = decoded['manifest'];
    final content = decoded['content'];
    if (manifest is! Map<String, dynamic> || content is! Map<String, dynamic>) {
      throw const FormatException('Package manifest or content is missing.');
    }
    String requiredText(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) throw FormatException('Manifest field "$key" is required.');
      return value.trim();
    }
    if (manifest['schema_version'] != 1) throw const FormatException('Unsupported package schema version.');
    if (requiredText(manifest, 'package_type') != 'hymn_collection') throw const FormatException('This installer accepts hymn collections only.');
    final id = requiredText(manifest, 'package_id');
    final name = requiredText(manifest, 'display_name');
    final language = requiredText(manifest, 'language_code');
    final normalizedLanguage = language.toLowerCase();
    if (normalizedLanguage != 'en' && !normalizedLanguage.startsWith('en-')) {
      throw const FormatException('Only English hymn collections are supported.');
    }
    final sourceName = requiredText(manifest, 'source_name');
    final sourceUrl = requiredText(manifest, 'source_url');
    final licenceName = requiredText(manifest, 'licence_name');
    final licenceUrl = requiredText(manifest, 'licence_url');
    final attribution = requiredText(manifest, 'attribution_text');
    final packageVersion = manifest['package_version'];
    if (packageVersion is! int || packageVersion < 1) throw const FormatException('package_version must be a positive integer.');
    final checksum = requiredText(manifest, 'checksum_sha256').toLowerCase();
    final calculated = sha256.convert(utf8.encode(jsonEncode(content))).toString();
    if (checksum != calculated) throw const FormatException('Package checksum does not match its content.');

    final rawHymns = content['hymns'];
    if (rawHymns is! List || rawHymns.isEmpty) throw const FormatException('The collection contains no hymns.');
    final seen = <String>{};
    final hymns = <Map<String, Object>>[];
    for (final item in rawHymns) {
      if (item is! Map<String, dynamic>) throw const FormatException('Each hymn must be a JSON object.');
      final title = item['title'];
      final lyrics = item['lyrics'];
      final number = item['hymn_number'];
      final firstLine = item['first_line'];
      if (title is! String || title.trim().isEmpty || lyrics is! String || lyrics.trim().isEmpty) {
        throw const FormatException('Every hymn must have a title and lyrics.');
      }
      if (number != null && number is! String && number is! int) throw const FormatException('hymn_number must be text or a number.');
      if (firstLine != null && firstLine is! String) throw const FormatException('first_line must be text.');
      final key = (number?.toString().trim().isNotEmpty ?? false) ? 'number:\${number.toString().trim()}' : 'title:\${title.trim().toLowerCase()}';
      if (!seen.add(key)) throw FormatException('Duplicate hymn entry: $key.');
      hymns.add({
        'title': title.trim(),
        'lyrics': lyrics.trim(),
        'hymn_number': number?.toString(),
        'first_line': (firstLine as String?)?.trim(),
      });
    }
    return ValidatedHymnPackage(
      id: id, name: name, languageCode: language, sourceName: sourceName,
      sourceUrl: sourceUrl, licenceName: licenceName, licenceUrl: licenceUrl,
      attribution: attribution, packageVersion: packageVersion, checksum: checksum,
      hymns: List.unmodifiable(hymns),
    );
  }

  Future<void> install(String source) async {
    final package = validate(source);
    final db = await _localDatabase.database;
    await db.transaction((txn) async {
      final existing = await txn.query('hymn_collections', columns: ['id'], where: 'id = ?', whereArgs: [package.id], limit: 1);
      if (existing.isNotEmpty) throw StateError('This hymn collection is already installed.');
      await txn.insert('hymn_collections', {
        'id': package.id, 'name': package.name, 'language_code': package.languageCode,
        'source_name': package.sourceName, 'licence_name': package.licenceName,
      });
      final batch = txn.batch();
      for (var i = 0; i < package.hymns.length; i++) {
        batch.insert('hymns', {
          ...package.hymns[i],
          'id': '\${package.id}-\${i + 1}',
          'collection_id': package.id,
          'language_code': package.languageCode,
          'source_name': package.sourceName,
          'licence_name': package.licenceName,
        });
      }
      await batch.commit(noResult: true);
      await txn.insert('installed_content_packages', {
        'package_id': package.id, 'package_type': 'hymn_collection',
        'package_version': package.packageVersion, 'display_name': package.name,
        'source_name': package.sourceName, 'licence_name': package.licenceName,
        'installed_at': DateTime.now().toUtc().toIso8601String(),
        'checksum_sha256': package.checksum,
      });
      await txn.insert('app_metadata', {'key': 'package_attribution_\${package.id}', 'value': package.attribution});
    });
  }
}
