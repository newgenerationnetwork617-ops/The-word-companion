import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'bible_catalog.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  static const schemaVersion = 1;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final directory = await getApplicationDocumentsDirectory();
    final file = p.join(directory.path, 'word_companion.db');
    _db = await openDatabase(
      file,
      version: schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    );
    return _db!;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('CREATE TABLE app_metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
    await db.execute('''CREATE TABLE bible_versions (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, abbreviation TEXT NOT NULL UNIQUE,
      language_code TEXT NOT NULL, source_name TEXT NOT NULL, licence_name TEXT NOT NULL,
      licence_url TEXT, installed_at TEXT NOT NULL, content_version INTEGER NOT NULL DEFAULT 1
    )''');
    await db.execute('''CREATE TABLE books (
      id INTEGER PRIMARY KEY, testament TEXT NOT NULL CHECK(testament IN ('OT','NT')),
      name TEXT NOT NULL, abbreviation TEXT NOT NULL, chapter_count INTEGER NOT NULL
    )''');
    await db.execute('''CREATE TABLE verses (
      id INTEGER PRIMARY KEY AUTOINCREMENT, version_id TEXT NOT NULL, book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL, verse_number INTEGER NOT NULL, text TEXT NOT NULL,
      FOREIGN KEY(version_id) REFERENCES bible_versions(id) ON DELETE CASCADE,
      FOREIGN KEY(book_id) REFERENCES books(id),
      UNIQUE(version_id, book_id, chapter_number, verse_number)
    )''');
    final bookBatch = db.batch();
    for (final book in bibleBooks) {
      bookBatch.insert('books', {
        'id': book.id,
        'testament': book.testament,
        'name': book.name,
        'abbreviation': book.abbreviation,
        'chapter_count': book.chapters,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await bookBatch.commit(noResult: true);
    await db.execute('CREATE INDEX idx_verses_reference ON verses(version_id, book_id, chapter_number, verse_number)');
    await db.execute('''CREATE TABLE cross_references (
      id INTEGER PRIMARY KEY AUTOINCREMENT, source_book_id INTEGER NOT NULL,
      source_chapter INTEGER NOT NULL, source_verse_start INTEGER NOT NULL,
      source_verse_end INTEGER NOT NULL, target_book_id INTEGER NOT NULL,
      target_chapter INTEGER NOT NULL, target_verse_start INTEGER NOT NULL,
      target_verse_end INTEGER NOT NULL, relationship_type TEXT NOT NULL,
      explanation TEXT NOT NULL, source_note TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE commentaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL, verse_start INTEGER, verse_end INTEGER,
      commentary_type TEXT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL,
      author_or_editor TEXT NOT NULL, source_name TEXT NOT NULL, licence_name TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE hymn_collections (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, language_code TEXT NOT NULL,
      source_name TEXT NOT NULL, licence_name TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE hymns (
      id TEXT PRIMARY KEY, collection_id TEXT NOT NULL, hymn_number TEXT,
      title TEXT NOT NULL, first_line TEXT, lyrics TEXT NOT NULL,
      language_code TEXT NOT NULL, source_name TEXT NOT NULL, licence_name TEXT NOT NULL,
      FOREIGN KEY(collection_id) REFERENCES hymn_collections(id) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT, version_id TEXT NOT NULL, book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL, verse_number INTEGER NOT NULL, created_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL, chapter_number INTEGER NOT NULL,
      verse_number INTEGER, note_text TEXT NOT NULL, updated_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE highlights (
      id INTEGER PRIMARY KEY AUTOINCREMENT, version_id TEXT NOT NULL, book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL, verse_number INTEGER NOT NULL,
      color_key TEXT NOT NULL, created_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE reading_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT, plan_id TEXT, book_id INTEGER NOT NULL,
      chapter_number INTEGER NOT NULL, completed_at TEXT NOT NULL,
      UNIQUE(plan_id, book_id, chapter_number)
    )''');
    await db.execute('''CREATE TABLE installed_content_packages (
      package_id TEXT PRIMARY KEY, package_type TEXT NOT NULL, package_version INTEGER NOT NULL,
      display_name TEXT NOT NULL, source_name TEXT NOT NULL, licence_name TEXT NOT NULL,
      installed_at TEXT NOT NULL, checksum_sha256 TEXT NOT NULL
    )''');

    try {
      await db.execute('''CREATE VIRTUAL TABLE IF NOT EXISTS verse_search USING fts5(
        version_id UNINDEXED, book_id UNINDEXED, chapter_number UNINDEXED,
        verse_number UNINDEXED, text, tokenize='unicode61'
      )''');
      await db.insert('app_metadata', {'key': 'verse_search_mode', 'value': 'fts5'}, conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException {
      // Some Android SQLite builds omit FTS5. Keep database setup working and
      // provide a basic indexed search store for the offline reader.
      await db.execute('''CREATE TABLE IF NOT EXISTS verse_search (
        id INTEGER PRIMARY KEY AUTOINCREMENT, version_id TEXT NOT NULL,
        book_id INTEGER NOT NULL, chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL, text TEXT NOT NULL
      )''');
      await db.execute('CREATE INDEX idx_verse_search_reference ON verse_search(version_id, book_id, chapter_number, verse_number)');
      await db.insert('app_metadata', {'key': 'verse_search_mode', 'value': 'basic'}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
