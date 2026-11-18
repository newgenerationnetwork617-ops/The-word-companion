import 'package:flutter/material.dart';
import '../../navigation/app_shell.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) => const SectionScaffold(
        title: 'The Bible',
        subtitle: 'Choose a book, chapter and translation to begin reading.',
        icon: Icons.menu_book_rounded,
      );
}
