import 'package:flutter/material.dart';
import 'slide_to_confirm_card.dart';

void main() {
  runApp(const HabitSliderApp());
}

class HabitSliderApp extends StatelessWidget {
  const HabitSliderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Slider',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      home: const HabitHomeScreen(),
    );
  }
}

/// A single hardcoded habit item.
class Habit {
  final String title;
  final String subtitle;
  final IconData icon;

  const Habit({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class HabitHomeScreen extends StatefulWidget {
  const HabitHomeScreen({super.key});

  @override
  State<HabitHomeScreen> createState() => _HabitHomeScreenState();
}

class _HabitHomeScreenState extends State<HabitHomeScreen> {
  // 5 hardcoded habits, fulfilling the "5+ items" requirement.
  final List<Habit> _habits = const [
    Habit(
        title: "Drink 3L of water",
        subtitle: "Slide to confirm",
        icon: Icons.local_drink),
    Habit(
        title: "Journal for 10 minutes",
        subtitle: "Slide to confirm",
        icon: Icons.menu_book),
    Habit(
        title: "Lift Weights",
        subtitle: "Slide to confirm",
        icon: Icons.fitness_center),
    Habit(
        title: "Meditate for 5 minutes",
        subtitle: "Slide to confirm",
        icon: Icons.self_improvement),
    Habit(
        title: "Phone off before bed",
        subtitle: "Slide to confirm",
        icon: Icons.nightlight_round),
  ];

  // Local state tracking which habits are completed today.
  final Set<int> _completedIndexes = {};

  void _markCompleted(int index) {
    setState(() {
      _completedIndexes.add(index);
    });
  }

  void _resetDay() {
    setState(() {
      _completedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _habits.length;
    final done = _completedIndexes.length;
    final allDone = done == total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Habits'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: 'Reset Day',
            icon: const Icon(Icons.refresh),
            onPressed: _resetDay,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _ProgressSummary(done: done, total: total),
          const SizedBox(height: 8),

          // Empty / completion / feedback state.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: allDone
                ? Container(
                    key: const ValueKey('done'),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: const [
                        Text('🎉', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All habits complete for today! Great job.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('not-done')),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final isCompleted = _completedIndexes.contains(index);
                return SlideToConfirmCard(
                  title: habit.title,
                  subtitle: habit.subtitle,
                  icon: habit.icon,
                  isCompleted: isCompleted,
                  onConfirmed: () => _markCompleted(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Small reusable widget showing "x of y done" plus a progress bar.
class _ProgressSummary extends StatelessWidget {
  final int done;
  final int total;

  const _ProgressSummary({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$done of $total habits done',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
