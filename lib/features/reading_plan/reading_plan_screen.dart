import 'package:flutter/material.dart';
import '../../data/reading_plan_repository.dart';

class ReadingPlanScreen extends StatefulWidget {
  const ReadingPlanScreen({super.key, this.repository, this.onOpenBible});
  final ReadingPlanRepository? repository;
  final VoidCallback? onOpenBible;
  @override
  State<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends State<ReadingPlanScreen> {
  late final ReadingPlanRepository _repository;
  final ReadingPlan _plan = ReadingPlan.sevenDaysInJohn;
  late Future<Set<int>> _completedFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReadingPlanRepository();
    _completedFuture = _repository.getCompletedDays(_plan);
  }

  Future<void> _setCompleted(ReadingPlanDay day, bool completed) async {
    await _repository.setDayCompleted(plan: _plan, day: day, completed: completed);
    if (!mounted) return;
    setState(() => _completedFuture = _repository.getCompletedDays(_plan));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reading plan')),
      body: FutureBuilder<Set<int>>(
        future: _completedFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Reading progress could not be loaded. Please try again.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final completed = snapshot.data!;
          final count = _plan.days.where((day) => completed.contains(day.chapter)).length;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(_plan.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(_plan.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Card(child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Your progress', style: theme.textTheme.titleMedium),
                    Text('$count of ${_plan.days.length} days'),
                  ]),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: count / _plan.days.length, minHeight: 8),
                  const SizedBox(height: 8),
                  Text(count == _plan.days.length ? 'Plan completed. Well done!' : 'Tick each day after you have completed the reading.', style: theme.textTheme.bodySmall),
                ]),
              )),
              const SizedBox(height: 18),
              Text('Daily readings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._plan.days.map((day) => Card(child: CheckboxListTile(
                value: completed.contains(day.chapter),
                onChanged: (value) => _setCompleted(day, value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('Day ${day.day} · ${day.reference}'),
                subtitle: Text(day.focus),
              ))),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: widget.onOpenBible, icon: const Icon(Icons.menu_book_outlined), label: const Text('Open Bible reader')),
              const SizedBox(height: 8),
              Text('Your progress is stored on this device and remains available offline.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}
