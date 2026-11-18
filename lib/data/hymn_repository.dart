import '../data/local_database.dart';

class HymnCollection {
  const HymnCollection({
    required this.id,
    required this.name,
    required this.sourceName,
    required this.licenceName,
    required this.hymnCount,
  });

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
  const HymnSummary({
    required this.id,
    required this.title,
    required this.collectionName,
    this.hymnNumber,
    this.firstLine,
  });

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

class HymnRepository {
  HymnRepository({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;

  Future<List<HymnCollection>> getCollections() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.source_name, c.licence_name,
             COUNT(h.id) AS hymn_count
      FROM hymn_collections c
      LEFT JOIN hymns h ON h.collection_id = c.id
      WHERE c.language_code = 'en'
      GROUP BY c.id, c.name, c.source_name, c.licence_name
      ORDER BY c.name COLLATE NOCASE
    ''');
    return rows.map(HymnCollection.fromMap).toList(growable: false);
  }

  Future<List<HymnSummary>> searchHymns(String query) async {
    final db = await _database.database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final rows = await db.rawQuery('''
      SELECT h.id, h.title, h.hymn_number, h.first_line,
             c.name AS collection_name
      FROM hymns h
      INNER JOIN hymn_collections c ON c.id = h.collection_id
      WHERE h.language_code = 'en'
        AND (h.title LIKE ? OR h.first_line LIKE ? OR h.lyrics LIKE ?)
      ORDER BY h.title COLLATE NOCASE
      LIMIT 100
    ''', ['%$trimmed%', '%$trimmed%', '%$trimmed%']);
    return rows.map(HymnSummary.fromMap).toList(growable: false);
  }
}
