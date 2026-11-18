import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_word_companion/navigation/app_shell.dart';

void main() {
  testWidgets('main navigation switches between app sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));

    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Bible'));
    await tester.pumpAndSettle();
    expect(find.text('The Bible'), findsOneWidget);

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(find.text('Study Scripture'), findsOneWidget);

    await tester.tap(find.text('Hymns'));
    await tester.pumpAndSettle();
    expect(find.text('Hymn Library'), findsOneWidget);
  });
}
