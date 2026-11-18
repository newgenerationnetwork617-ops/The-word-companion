import 'package:flutter/material.dart';

import '../navigation/app_shell.dart';
import 'app_theme.dart';

class TheWordCompanionApp extends StatelessWidget {
  const TheWordCompanionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'The Word Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AppShell(),
      );
}
