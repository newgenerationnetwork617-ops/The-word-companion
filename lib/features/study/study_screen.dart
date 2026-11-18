import 'package:flutter/material.dart';
import '../../navigation/app_shell.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) => const SectionScaffold(
        title: 'Study Scripture',
        subtitle: 'Explore explanations, context, practical applications and cross-references.',
        icon: Icons.auto_stories_rounded,
      );
}
