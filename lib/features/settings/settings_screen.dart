import 'package:flutter/material.dart';
import '../../navigation/app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SectionScaffold(
        title: 'Settings',
        subtitle: 'Personalise reading, appearance, storage and reminders.',
        icon: Icons.tune_rounded,
      );
}
