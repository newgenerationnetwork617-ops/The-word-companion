import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'hymn_package_importer.dart';
import 'local_database.dart';

/// Installs original hymn collections bundled in the APK. No network access.
class BundledHymnInstaller {
  BundledHymnInstaller({
    LocalDatabase? database,
    HymnPackageImporter? importer,
    AssetBundle? assets,
  })  : _database = database ?? LocalDatabase.instance,
        _importer = importer ?? HymnPackageImporter(localDatabase: database),
        _assets = assets ?? rootBundle;

  final LocalDatabase _database;
  final HymnPackageImporter _importer;
  final AssetBundle _assets;

  static const packageAssets = <String>[
    'assets/hymns/twc-original-praise.json',
    'assets/hymns/twc-scripture-songs.json',
  ];

  Future<void> installAvailablePackages() async {
    final db = await _database.database;
    for (final assetPath in packageAssets) {
      final source = await _assets.loadString(assetPath);
      final validated = HymnPackageImporter.validate(source);
      final existing = await db.query(
        'installed_content_packages',
        columns: ['checksum_sha256', 'package_version'],
        where: 'package_id = ?',
        whereArgs: [validated.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final row = existing.first;
        if (row['checksum_sha256'] == validated.checksum &&
            row['package_version'] == validated.packageVersion) {
          continue;
        }
        throw StateError(
          'Bundled hymn collection ${validated.name} changed. '
          'A safe content migration is required before replacing it.',
        );
      }
      await _importer.install(source);
    }
  }
}
