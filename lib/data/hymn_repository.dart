import 'local_database.dart';

class HymnCollection {
  const HymnCollection({required this.id, required this.name, required this.sourceName, required this.licenceName, required this.hymnCount});
  final String id;
  final String name;
  final String sourceName;
  final String licenceName;
  final int hymnCount;
  factory HymnCollection.fromMap(Map<String, Object?> row) => HymnCollection(
    id: row['id']! as String,
    name: row['name']! as String,
    sourceName: row['source_name']! as String,
    licenceName: row['licence_name']! as String,
    hymnCount: row['hymn_count']! as int,
  );
}

class HymnSummary {
  const HymnSummary({required this.id, required this.title, required this.collectionName, this.hymnNumber, this.firstLine});
  final String id;
  final String title;
  final String collectionName;
  final String? hymnNumber;
  final String? firstLine;
  factory HymnSummary.fromMap(Map<String, Object?> row) => HymnSummary(
    id: row['id']! as String,
    title: row['title']! as String,
    collectionName: row['collection_name']! as String,
    hymnNumber: row['hymn_number'] as String?,
    firstLine: row['first_line'] as String?,
  );
}

class HymnEntry {
  const HymnEntry({required this.id, required this.title, required this.lyrics, required this.collectionName, required this.sourceName, required this.licenceName, this.hymnNumber});
  final String id;
  final String title;
  final String lyrics;
  final String collectionName;
  final String sourceName;
  final String licenceName;
  final String? hymnNumber;
}

class HymnRepository {
  HymnRepository({LocalDatabase? database}) : _database = database ?? LocalDatabase.instance;
  final LocalDatabase _database;

  Future<List<HymnCollection>> getCollections() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.source_name, c.licence_name, COUNT(h.id) AS hymn_count
      FROM hymn_collections c LEFT JOIN hymns h ON h.collection_id = c.id
      WHERE c.language_code LIKE 'en%'
      GROUP BY c.id, c.name, c.source_name, c.licence_name
      ORDER BY c.name COLLATE NOCASE
    ''');
    return rows.map(HymnCollection.fromMap).toList(growable: false);
  }

  Future<List<HymnSummary>> searchHymns(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT h.id, h.title, h.hymn_number, h.first_line, c.name AS collection_name
      FROM hymns h INNER JOIN hymn_collections c ON c.id = h.collection_id
      WHERE h.language_code LIKE 'en%' AND (h.title LIKE ? OR h.first_line LIKE ? OR h.lyrics LIKE ?)
      ORDER BY h.title COLLATE NOCASE LIMIT 100
    ''', ['%$trimmed%', '%$trimmed%', '%$trimmed%']);
    return rows.map(HymnSummary.fromMap).toList(growable: false);
  }

  Future<List<HymnSummary>> getHymnsForCollection(String collectionId) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT h.id, h.title, h.hymn_number, h.first_line, c.name AS collection_name
      FROM hymns h INNER JOIN hymn_collections c ON c.id = h.collection_id
      WHERE h.collection_id = ? AND h.language_code LIKE 'en%'
      ORDER BY CAST(h.hymn_number AS INTEGER), h.title COLLATE NOCASE
    ''', [collectionId]);
    return rows.map(HymnSummary.fromMap).toList(growable: false);
  }

  Future<HymnEntry?> getHymn(String id) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT h.id, h.title, h.lyrics, h.hymn_number, h.source_name, h.licence_name,
             c.name AS collection_name
      FROM hymns h INNER JOIN hymn_collections c ON c.id = h.collection_id
      WHERE h.id = ? AND h.language_code LIKE 'en%' LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return HymnEntry(
      id: row['id']! as String,
      title: row['title']! as String,
      lyrics: row['lyrics']! as String,
      collectionName: row['collection_name']! as String,
      sourceName: row['source_name']! as String,
      licenceName: row['licence_name']! as String,
      hymnNumber: row['hymn_number'] as String?,
    );
  }
}
