import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class BibleVersion {
 const BibleVersion({required this.id,required this.name,required this.abbreviation});
 final String id,name,abbreviation;
 factory BibleVersion.fromMap(Map<String,Object?> m)=>BibleVersion(id:m['id']! as String,name:m['name']! as String,abbreviation:m['abbreviation']! as String);
}
class BibleVerse {
 const BibleVerse({required this.number,required this.text});
 final int number; final String text;
 factory BibleVerse.fromMap(Map<String,Object?> m)=>BibleVerse(number:m['verse_number']! as int,text:m['text']! as String);
}
class BibleRepository {
 BibleRepository({LocalDatabase? localDatabase}):_localDatabase=localDatabase??LocalDatabase.instance;
 final LocalDatabase _localDatabase;
 Future<List<BibleVersion>> getInstalledVersions() async {
  final db=await _localDatabase.database;
  final rows=await db.query('bible_versions',orderBy:'name COLLATE NOCASE');
  return rows.map(BibleVersion.fromMap).toList(growable:false);
 }
 Future<List<BibleVerse>> getChapter({required String versionId,required int bookId,required int chapter}) async {
  final db=await _localDatabase.database;
  final rows=await db.query('verses',columns:['verse_number','text'],where:'version_id = ? AND book_id = ? AND chapter_number = ?',whereArgs:[versionId,bookId,chapter],orderBy:'verse_number');
  return rows.map(BibleVerse.fromMap).toList(growable:false);
 }
}
