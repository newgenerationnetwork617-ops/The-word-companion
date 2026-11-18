import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../bible/bible_screen.dart';

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
              _StudySection(
                icon: Icons.lightbulb_outline,
                title: 'Understand',
                description:
                    'A clear explanation of the verse and its immediate meaning.',
              ),
              _StudySection(
                icon: Icons.menu_book_outlined,
                title: 'Explore',
                description:
                    'Historical, literary and biblical context for deeper study.',
              ),
              _StudySection(
                icon: Icons.directions_outlined,
                title: 'Apply',
                description:
                    'Practical ways to put the teaching into everyday life.',
              ),
              _StudySection(
                icon: Icons.link,
                title: 'Connect',
                description:
                    'Related Scripture passages with an explanation of each connection.',
              ),
              _StudySection(
                icon: Icons.self_improvement_outlined,
                title: 'Reflect',
                description:
                    'Questions to help you think carefully about the passage.',
              ),
              const SizedBox(height: 8),
              const Text(
                'These study sections are the planned structure. Reviewed offline commentary and cross-reference content will be added before the study feature is considered complete.',
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
