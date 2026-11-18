import 'local_database.dart';

class BibleVersion {
  const BibleVersion({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final String id;
  final String name;
  final String abbreviation;

  factory BibleVersion.fromMap(Map<String, Object?> map) => BibleVersion(
        id: map['id']! as String,
        name: map['name']! as String,
        abbreviation: map['abbreviation']! as String,
      );
}

class BibleVerse {
  const BibleVerse({
    required this.number,
    required this.text,
    this.isBookmarked = false,
    this.highlightColor,
    this.hasNote = false,
  });

  final int number;
  final String text;
  final bool isBookmarked;
  final String? highlightColor;
  final bool hasNote;

  factory BibleVerse.fromMap(Map<String, Object?> map) => BibleVerse(
        number: map['verse_number']! as int,
        text: map['text']! as String,
      );
}

class BibleRepository {
  BibleRepository({LocalDatabase? localDatabase})
      : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  Future<List<BibleVersion>> getInstalledVersions() async {
    final db = await _localDatabase.database;
    final rows = await db.query('bible_versions', orderBy: 'name COLLATE NOCASE');
    return rows.map(BibleVersion.fromMap).toList(growable: false);
  }

  Future<List<BibleVerse>> getChapter({
    required String versionId,
    required int bookId,
    required int chapter,
  }) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'verses',
      columns: ['verse_number', 'text'],
      where: 'version_id = ? AND book_id = ? AND chapter_number = ?',
      whereArgs: [versionId, bookId, chapter],
      orderBy: 'verse_number',
    );
    if (rows.isEmpty) return const [];

    final bookmarks = await db.query(
      'bookmarks',
      columns: ['verse_number'],
      where: 'version_id = ? AND book_id = ? AND chapter_number = ?',
      whereArgs: [versionId, bookId, chapter],
    );
    final highlights = await db.query(
      'highlights',
      columns: ['verse_number', 'color_key'],
      where: 'version_id = ? AND book_id = ? AND chapter_number = ?',
      whereArgs: [versionId, bookId, chapter],
    );
    final notes = await db.query(
      'notes',
      columns: ['verse_number'],
      where: 'book_id = ? AND chapter_number = ? AND verse_number IS NOT NULL',
      whereArgs: [bookId, chapter],
    );

    final bookmarkedNumbers =
        bookmarks.map((row) => row['verse_number']! as int).toSet();
    final highlightByNumber = <int, String>{};
    for (final row in highlights) {
      highlightByNumber[row['verse_number']! as int] =
          row['color_key']! as String;
    }
    final notedNumbers =
        notes.map((row) => row['verse_number']! as int).toSet();

    return rows.map((row) {
      final number = row['verse_number']! as int;
      return BibleVerse(
        number: number,
        text: row['text']! as String,
        isBookmarked: bookmarkedNumbers.contains(number),
        highlightColor: highlightByNumber[number],
        hasNote: notedNumbers.contains(number),
      );
    }).toList(growable: false);
  }

  Future<bool> toggleBookmark({
    required String versionId,
    required int bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await _localDatabase.database;
    final where =
        'version_id = ? AND book_id = ? AND chapter_number = ? AND verse_number = ?';
    final args = [versionId, bookId, chapter, verse];
    final existing = await db.query('bookmarks', where: where, whereArgs: args, limit: 1);
    if (existing.isNotEmpty) {
      await db.delete('bookmarks', where: where, whereArgs: args);
      return false;
    }
    await db.insert('bookmarks', {
      'version_id': versionId,
      'book_id': bookId,
      'chapter_number': chapter,
      'verse_number': verse,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return true;
  }

  Future<void> setHighlight({
    required String versionId,
    required int bookId,
    required int chapter,
    required int verse,
    required String? colorKey,
  }) async {
    final db = await _localDatabase.database;
    const where =
        'version_id = ? AND book_id = ? AND chapter_number = ? AND verse_number = ?';
    final args = <Object>[versionId, bookId, chapter, verse];
    await db.delete('highlights', where: where, whereArgs: args);
    if (colorKey != null) {
      await db.insert('highlights', {
        'version_id': versionId,
        'book_id': bookId,
        'chapter_number': chapter,
        'verse_number': verse,
        'color_key': colorKey,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<String?> getNote({
    required int bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'notes',
      columns: ['note_text'],
      where: 'book_id = ? AND chapter_number = ? AND verse_number = ?',
      whereArgs: [bookId, chapter, verse],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['note_text']! as String;
  }

  Future<void> saveNote({
    required int bookId,
    required int chapter,
    required int verse,
    required String noteText,
  }) async {
    final db = await _localDatabase.database;
    const where = 'book_id = ? AND chapter_number = ? AND verse_number = ?';
    final args = [bookId, chapter, verse];
    final existing = await db.query('notes', columns: ['id'], where: where, whereArgs: args, limit: 1);
    if (noteText.trim().isEmpty) {
      await db.delete('notes', where: where, whereArgs: args);
      return;
    }
    final values = {
      'note_text': noteText.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (existing.isEmpty) {
      await db.insert('notes', {
        ...values,
        'book_id': bookId,
        'chapter_number': chapter,
        'verse_number': verse,
      });
    } else {
      await db.update('notes', values, where: where, whereArgs: args);
    }
  }
}
