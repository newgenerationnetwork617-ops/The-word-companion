import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/data/reading_plan_repository.dart';

void main() {
  test('available reading plans have seven distinct daily readings', () {
    expect(ReadingPlan.available, hasLength(2));
    for (final plan in ReadingPlan.available) {
      expect(plan.days, hasLength(7));
      expect(plan.days.map((day) => day.day).toSet(), hasLength(7));
      expect(plan.days.map((day) => day.chapter).toSet(), hasLength(7));
      expect(plan.title, isNotEmpty);
      expect(plan.description, isNotEmpty);
      for (final day in plan.days) {
        expect(day.reference, isNotEmpty);
        expect(day.focus, isNotEmpty);
        expect(day.bookId, greaterThan(0));
        expect(day.chapter, greaterThan(0));
      }
    }
  });

  test('Psalms plan stays within the Psalms book for local progress tracking', () {
    final plan = ReadingPlan.sevenDaysInPsalms;
    expect(plan.days.every((day) => day.bookId == 19), isTrue);
    expect(plan.days.map((day) => day.chapter).toList(),
        [1, 23, 27, 46, 91, 121, 139]);
  });
}
