import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'local_database.dart';
import 'bible_package_importer.dart';

/// Installs Scripture packages shipped inside the APK. This service never
/// accesses the network; package bytes are read from Flutter's asset bundle.
class BundledBibleInstaller {
  BundledBibleInstaller({
    LocalDatabase? localDatabase,
    BiblePackageImporter? importer,
    AssetBundle? assetBundle,
  })  : _database = localDatabase ?? LocalDatabase.instance,
        _importer = importer ?? BiblePackageImporter(localDatabase: localDatabase),
        _assets = assetBundle ?? rootBundle;

  final LocalDatabase _database;
  final BiblePackageImporter _importer;
  final AssetBundle _assets;

  /// Asset paths are explicit so a missing asset is caught during development
  /// and cannot silently trigger an online download.
  static const packageAssets = <String>[
    'assets/bible/kjv.json',
    'assets/bible/asv.json',
    'assets/bible/web.json',
    'assets/bible/geneva1599.json',
    'assets/bible/webu.json',
  ];

  Future<void> installAvailablePackages() async {
    if (packageAssets.isEmpty) return;
    final db = await _database.database;
    for (final assetPath in packageAssets) {
      final source = await _assets.loadString(assetPath);
      final validated = BiblePackageImporter.validate(source);
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
          'Bundled translation ${validated.abbreviation} changed. '
          'A safe content migration is required before replacing it.',
        );
      }
      await _importer.install(source);
    }
  }
}
