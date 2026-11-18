import 'package:flutter/material.dart';

import '../data/bible_repository.dart';
import '../features/bible/bible_screen.dart';
import '../features/home/home_screen.dart';
import '../features/hymns/hymns_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/study/study_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.bibleRepository});

  final BibleRepository? bibleRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  VerseStudySelection? _selectedVerse;


  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      BibleScreen(
        repository: widget.bibleRepository,
        onStudyVerse: (selection) => setState(() {
          _selectedVerse = selection;
          _index = 2;
        }),
      ),
      StudyScreen(selection: _selectedVerse),
      const HymnsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
        body: IndexedStack(index: _index, children: screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bible'),
            NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Study'),
            NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Hymns'),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
          ],
        ),
      );
  }
}

class SectionScaffold extends StatelessWidget {
  const SectionScaffold({required this.title, required this.subtitle, required this.icon, super.key});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('The Word Companion')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                const Spacer(),
                Center(child: Icon(icon, size: 54, color: Theme.of(context).colorScheme.secondary)),
                const SizedBox(height: 16),
                const Center(child: Text('This section will be built in the next development stages.')),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}
