import 'package:flutter/material.dart';
import '../../navigation/app_shell.dart';

class HymnsScreen extends StatelessWidget {
  const HymnsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SectionScaffold(
        title: 'Hymn Library',
        subtitle: 'Browse and search trusted hymn collections.',
        icon: Icons.library_music_rounded,
      );
}
