import 'package:flutter/material.dart';

import '../bible/bible_screen.dart';
import '../../data/study_content.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, this.selection});

  final VerseStudySelection? selection;

  @override
  Widget build(BuildContext context) {
    final selected = selection;
    return Scaffold(
      appBar: AppBar(title: const Text('The Word Companion')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Study Scripture',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore explanations, context, practical applications and cross-references.',
            ),
            const SizedBox(height: 20),
            if (selected == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Open the Bible, select a verse, and choose “Study this verse” to bring it here.',
                  ),
                ),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selected.reference,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(selected.text,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (studyGuides[selected.reference] case final guide?) ...[
                _StudySection(
                  icon: Icons.lightbulb_outline,
                  title: 'Understand',
                  description: guide.understand,
                ),
                _StudySection(
                  icon: Icons.menu_book_outlined,
                  title: 'Explore',
                  description: guide.context,
                ),
                _StudySection(
                  icon: Icons.directions_outlined,
                  title: 'Apply',
                  description: guide.apply,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.link),
                            const SizedBox(width: 10),
                            Text('Connect', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (final connection in guide.connections)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(connection.reference, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(connection.reason),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.self_improvement_outlined),
                            const SizedBox(width: 10),
                            Text('Reflect', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < guide.reflection.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text('${i + 1}. ${guide.reflection[i]}'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Study notes are original editorial aids. Read the surrounding Bible passage and compare translations as you study.'),
              ] else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'A full study guide for this verse has not been added yet. The study library is being expanded with contextual explanations, practical application and explained cross-references. For now, read the surrounding chapter and compare the available translations.',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudySection extends StatelessWidget {
  const _StudySection({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(description),
        ),
      );
}
