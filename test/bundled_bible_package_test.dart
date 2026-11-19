import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/bible_package_importer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled WEBU package is complete and checksum-valid', () async {
    final source = await rootBundle.loadString('assets/bible/webu.json');
    final package = BiblePackageImporter.validate(source);

    expect(package.id, 'webu');
    expect(package.abbreviation, 'WEBU');
    expect(package.languageCode, 'en');
    expect(package.verses, hasLength(31098));
    expect(package.verses.map((verse) => verse['book_id']).toSet(), hasLength(66));
  });
}
