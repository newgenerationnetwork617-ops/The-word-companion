import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onStartReading, this.onOpenReadingPlan});
  final VoidCallback? onStartReading;
  final VoidCallback? onOpenReadingPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Word Companion', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(tooltip: 'Reading plan and progress', onPressed: onOpenReadingPlan, icon: const Icon(Icons.history_rounded))],
      ),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('Welcome', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Make room for the Word today.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: dark ? const [AppTheme.navy, Color(0xFF263A53)] : const [AppTheme.navy, Color(0xFF263F5C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR DAILY JOURNEY', style: TextStyle(color: Color(0xFFE2C27F), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              const Text('Read the Word.\nUnderstand the Word.\nLive the Word.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.25, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              FilledButton.tonalIcon(onPressed: onStartReading, icon: const Icon(Icons.menu_book_rounded), label: const Text('Start reading'), style: FilledButton.styleFrom(foregroundColor: AppTheme.navyDeep, backgroundColor: const Color(0xFFE2C27F))),
            ]),
          ),
          const SizedBox(height: 18),
          Card(child: ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('Seven days in the Gospel of John', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('A guided reading plan with progress saved offline.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onOpenReadingPlan,
          )),
          const SizedBox(height: 26),
          Text('Explore your library', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          const _FeatureTile(icon: Icons.menu_book_outlined, title: 'Read the Bible', description: 'Browse Scripture and compare translations.'),
          const SizedBox(height: 10),
          const _FeatureTile(icon: Icons.account_tree_outlined, title: 'Cross-references', description: 'Discover how passages connect across the Bible.'),
          const SizedBox(height: 10),
          const _FeatureTile(icon: Icons.lightbulb_outline_rounded, title: 'Understand and apply', description: 'Explore context, explanations and practical lessons.'),
          const SizedBox(height: 10),
          const _FeatureTile(icon: Icons.library_music_outlined, title: 'Hymn collections', description: 'Keep meaningful hymns together in one library.'),
          const SizedBox(height: 18),
          Text('Installed content will be available offline.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        ],
      )),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondaryContainer, child: Icon(icon, color: Theme.of(context).colorScheme.onSecondaryContainer)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(description),
    trailing: const Icon(Icons.chevron_right_rounded),
  ));
}
