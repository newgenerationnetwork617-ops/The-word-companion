import 'package:flutter/material.dart';
import '../data/bible_repository.dart';
import '../data/hymn_repository.dart';
import '../features/bible/bible_screen.dart';
import '../features/home/home_screen.dart';
import '../features/hymns/hymns_screen.dart';
import '../features/reading_plan/reading_plan_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/study/study_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.bibleRepository, this.hymnRepository});
  final BibleRepository? bibleRepository;
  final HymnRepository? hymnRepository;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  VerseStudySelection? _selectedVerse;

  void _openReadingPlan() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReadingPlanScreen(onOpenBible: () {
        Navigator.of(context).pop();
        setState(() => _index = 1);
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onStartReading: () => setState(() => _index = 1), onOpenReadingPlan: _openReadingPlan),
      BibleScreen(repository: widget.bibleRepository, onStudyVerse: (selection) => setState(() {
        _selectedVerse = selection;
        _index = 2;
      })),
      StudyScreen(selection: _selectedVerse),
      HymnsScreen(repository: widget.hymnRepository),
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
