import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class ReadingPlanDay {
  const ReadingPlanDay({required this.day, required this.reference, required this.bookId, required this.chapter, required this.focus});
  final int day;
  final String reference;
  final int bookId;
  final int chapter;
  final String focus;
}
class ReadingPlan {
  const ReadingPlan({required this.id, required this.title, required this.description, required this.days});
  final String id;
  final String title;
  final String description;
  final List<ReadingPlanDay> days;
  static const sevenDaysInJohn = ReadingPlan(
    id: 'seven-days-in-john',
    title: 'Seven Days in the Gospel of John',
    description: 'A one-week reading journey through key chapters about Jesus.',
    days: [
      ReadingPlanDay(day: 1, reference: 'John 1', bookId: 43, chapter: 1, focus: 'The Word and the beginning of Jesus’ ministry'),
      ReadingPlanDay(day: 2, reference: 'John 3', bookId: 43, chapter: 3, focus: 'New life and God’s love'),
      ReadingPlanDay(day: 3, reference: 'John 4', bookId: 43, chapter: 4, focus: 'Worship and living water'),
      ReadingPlanDay(day: 4, reference: 'John 6', bookId: 43, chapter: 6, focus: 'Jesus, the bread of life'),
      ReadingPlanDay(day: 5, reference: 'John 10', bookId: 43, chapter: 10, focus: 'The good shepherd'),
      ReadingPlanDay(day: 6, reference: 'John 15', bookId: 43, chapter: 15, focus: 'Abiding in Christ'),
      ReadingPlanDay(day: 7, reference: 'John 20', bookId: 43, chapter: 20, focus: 'The resurrection of Jesus'),
    ],
  );
}
class ReadingPlanRepository {
  ReadingPlanRepository({LocalDatabase? database}) : _database = database ?? LocalDatabase.instance;
  final LocalDatabase _database;

  Future<Set<int>> getCompletedDays(ReadingPlan plan) async {
    if (plan.days.isEmpty) return {};
    final db = await _database.database;
    final rows = await db.query('reading_progress', columns: ['chapter_number'], where: 'plan_id = ? AND book_id = ?', whereArgs: [plan.id, plan.days.first.bookId]);
    return rows.map((row) => row['chapter_number']! as int).toSet();
  }

  Future<void> setDayCompleted({required ReadingPlan plan, required ReadingPlanDay day, required bool completed}) async {
    final db = await _database.database;
    const where = 'plan_id = ? AND book_id = ? AND chapter_number = ?';
    final args = [plan.id, day.bookId, day.chapter];
    if (!completed) {
      await db.delete('reading_progress', where: where, whereArgs: args);
      return;
    }
    await db.insert('reading_progress', {
      'plan_id': plan.id,
      'book_id': day.bookId,
      'chapter_number': day.chapter,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
