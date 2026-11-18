import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/bible_catalog.dart';
import 'package:the_word_companion/data/bible_repository.dart';
import 'package:the_word_companion/features/bible/bible_screen.dart';
import 'package:the_word_companion/navigation/app_shell.dart';

class _EmptyBibleRepository extends BibleRepository {
 @override Future<List<BibleVersion>> getInstalledVersions() async => [];
}

class _SampleBibleRepository extends BibleRepository {
 @override Future<List<BibleVersion>> getInstalledVersions() async => [
  const BibleVersion(id: 'sample-en', name: 'Sample English', abbreviation: 'SEN'),
 ];
 @override Future<List<BibleVerse>> getChapter({required String versionId, required int bookId, required int chapter}) async => [
  const BibleVerse(number: 1, text: 'In the beginning God created the heavens and the earth.'),
 ];
}
void main(){
 test('Bible catalogue contains the 66 books in canonical order',(){
  expect(bibleBooks,hasLength(66));expect(bibleBooks.first.name,'Genesis');expect(bibleBooks.last.name,'Revelation');
  expect(bibleBooks.where((b)=>b.testament=='OT'),hasLength(39));expect(bibleBooks.where((b)=>b.testament=='NT'),hasLength(27));
  expect(bibleBooks.firstWhere((b)=>b.name=='Psalms').chapters,150);
 });
 testWidgets('Bible reader clearly reports missing translation content',(tester)async{
  await tester.pumpWidget(MaterialApp(home:BibleScreen(repository:_EmptyBibleRepository())));
  await tester.pumpAndSettle();
  expect(find.text('Bible reader'),findsOneWidget);
  expect(find.textContaining('No Bible translation is installed yet.'),findsOneWidget);
 });
 testWidgets('a selected verse opens the Study Scripture workspace',(tester)async{
  await tester.pumpWidget(MaterialApp(home:AppShell(bibleRepository:_SampleBibleRepository())));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bible')); await tester.pumpAndSettle();
  await tester.tap(find.text('Choose a translation')); await tester.pumpAndSettle();
  await tester.tap(find.text('Sample English (SEN)')); await tester.pumpAndSettle();
  await tester.tap(find.text('In the beginning God created the heavens and the earth.'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Study this verse')); await tester.pumpAndSettle();
  expect(find.text('Study Scripture'),findsOneWidget);
  expect(find.text('Genesis 1:1'),findsOneWidget);
  expect(find.text('Understand'),findsOneWidget);
 });
 testWidgets('main navigation switches between app sections',(tester)async{
  await tester.pumpWidget(MaterialApp(home:AppShell(bibleRepository:_EmptyBibleRepository())));await tester.pumpAndSettle();expect(find.text('Welcome'),findsOneWidget);
  await tester.tap(find.text('Bible'));await tester.pumpAndSettle();expect(find.text('Bible reader'),findsOneWidget);
  await tester.tap(find.text('Study'));await tester.pumpAndSettle();expect(find.text('Study Scripture'),findsOneWidget);
  await tester.tap(find.text('Hymns'));await tester.pumpAndSettle();expect(find.text('Hymn Library'),findsOneWidget);
 });
}
