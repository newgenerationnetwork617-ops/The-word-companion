import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/bible_repository.dart';
import 'package:the_word_companion/data/study_content.dart';

class _TwoTranslationRepository extends BibleRepository {
  @override
  Future<List<BibleVersion>> getInstalledVersions() async => const [
        BibleVersion(id: 'kjv', name: 'King James Version', abbreviation: 'KJV'),
        BibleVersion(id: 'web', name: 'World English Bible', abbreviation: 'WEB'),
      ];

  @override
  Future<List<BibleVerse>> getChapter({
    required String versionId,
    required int bookId,
    required int chapter,
  }) async =>
      [
        BibleVerse(
          number: 1,
          text: versionId == 'kjv' ? 'KJV sample verse' : 'WEB sample verse',
        ),
      ];
}

void main() {
  test('chapter comparison returns content from every installed translation', () async {
    final result = await _TwoTranslationRepository().getChapterAcrossVersions(
      bookId: 1,
      chapter: 1,
    );

    expect(result, hasLength(2));
    expect(result.keys.map((version) => version.abbreviation), containsAll(['KJV', 'WEB']));
    expect(result.values.expand((verses) => verses).map((verse) => verse.text),
        containsAll(['KJV sample verse', 'WEB sample verse']));
  });

  test('starter study library has all five study sections for key verses', () {
    expect(studyGuides.keys, containsAll([
      'John 3:16',
      'Psalm 23:1',
      'Romans 8:28',
      'Proverbs 3:5',
      'Philippians 4:6',
      'Matthew 6:33',
      'Micah 6:8',
      'James 1:5',
      'Ephesians 2:8',
      'Galatians 5:22',
    ]));
    for (final guide in studyGuides.values) {
      expect(guide.understand, isNotEmpty);
      expect(guide.context, isNotEmpty);
      expect(guide.apply, isNotEmpty);
      expect(guide.connections, isNotEmpty);
      expect(guide.reflection, isNotEmpty);
    }
  });
}
