import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/bible_catalog.dart';
import 'package:the_word_companion/data/bible_repository.dart';
import 'package:the_word_companion/data/hymn_repository.dart';
import 'package:the_word_companion/data/reading_plan_repository.dart';
import 'package:the_word_companion/features/bible/bible_screen.dart';
import 'package:the_word_companion/features/reading_plan/reading_plan_screen.dart';
import 'package:the_word_companion/navigation/app_shell.dart';

class _EmptyBibleRepository extends BibleRepository {
  @override
  Future<List<BibleVersion>> getInstalledVersions() async => [];
}
class _SampleBibleRepository extends BibleRepository {
  @override
  Future<List<BibleVersion>> getInstalledVersions() async => [const BibleVersion(id: 'sample-en', name: 'Sample English', abbreviation: 'SEN')];
  @override
  Future<List<BibleVerse>> getChapter({required String versionId, required int bookId, required int chapter}) async => [const BibleVerse(number: 1, text: 'In the beginning God created the heavens and the earth.')];
  @override
  Future<String?> getNote({required int bookId, required int chapter, required int verse}) async => null;
}
class _EmptyHymnRepository extends HymnRepository {
  @override
  Future<List<HymnCollection>> getCollections() async => [];
  @override
  Future<List<HymnSummary>> searchHymns(String query) async => [];
}
class _MemoryReadingPlanRepository extends ReadingPlanRepository {
  final Set<int> completed = {};
  @override
  Future<Set<int>> getCompletedDays(ReadingPlan plan) async => Set<int>.from(completed);
  @override
  Future<void> setDayCompleted({required ReadingPlan plan, required ReadingPlanDay day, required bool completed}) async {
    if (completed) { this.completed.add(day.chapter); } else { this.completed.remove(day.chapter); }
  }
}

void main() {
  test('Bible catalogue contains the 66 books in canonical order', () {
    expect(bibleBooks, hasLength(66));
    expect(bibleBooks.first.name, 'Genesis');
    expect(bibleBooks.last.name, 'Revelation');
    expect(bibleBooks.where((book) => book.testament == 'OT'), hasLength(39));
    expect(bibleBooks.where((book) => book.testament == 'NT'), hasLength(27));
    expect(bibleBooks.firstWhere((book) => book.name == 'Psalms').chapters, 150);
  });
  testWidgets('Bible reader clearly reports missing translation content', (tester) async {
    await tester.pumpWidget(MaterialApp(home: BibleScreen(repository: _EmptyBibleRepository())));
    await tester.pumpAndSettle();
    expect(find.text('Bible reader'), findsOneWidget);
    expect(find.textContaining('No English Bible translation is installed yet.'), findsOneWidget);
  });
  testWidgets('a selected verse opens the Study Scripture workspace', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AppShell(bibleRepository: _SampleBibleRepository(), hymnRepository: _EmptyHymnRepository())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bible'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sample English (SEN)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In the beginning God created the heavens and the earth.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study this verse'));
    await tester.pumpAndSettle();
    expect(find.text('Study Scripture'), findsOneWidget);
    expect(find.text('Genesis 1:1'), findsOneWidget);
    expect(find.textContaining('A full study guide for this verse has not been added yet.'), findsOneWidget);
  });
  testWidgets('main navigation switches between app sections', (tester) async {
    await tester.pumpWidget(MaterialApp(home: AppShell(bibleRepository: _EmptyBibleRepository(), hymnRepository: _EmptyHymnRepository())));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    await tester.tap(find.text('Bible'));
    await tester.pumpAndSettle();
    expect(find.text('Bible reader'), findsOneWidget);
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(find.text('Study Scripture'), findsOneWidget);
    await tester.tap(find.text('Hymns'));
    await tester.pumpAndSettle();
    expect(find.text('Hymn Library'), findsOneWidget);
  });
  testWidgets('reading plan shows progress and saves a completed day offline', (tester) async {
    final repository = _MemoryReadingPlanRepository();
    await tester.pumpWidget(MaterialApp(home: ReadingPlanScreen(repository: repository)));
    await tester.pumpAndSettle();
    expect(find.text('Seven Days in the Gospel of John'), findsOneWidget);
    expect(find.text('0 of 7 days'), findsOneWidget);
    await tester.tap(find.textContaining('Day 1'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 7 days'), findsOneWidget);
    expect(repository.completed, contains(1));
  });
}
