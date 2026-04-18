import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/journal_provider.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../data/models/journal_entry.dart';
import 'history_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  String _selectedMood = 'Calm'; // Default to Calm

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  void _saveReflection() {
    final session = ref.read(sessionProvider);
    if (_reflectionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your reflection')),
      );
      return;
    }

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active session')),
      );
      return;
    }

    final entry = JournalEntry(
      id: DateTime.now().toString(),
      sessionId: session.id,
      reflection: _reflectionController.text,
      mood: _selectedMood,
      createdAt: DateTime.now(),
    );

    ref.read(journalProvider.notifier).addEntry(entry);

    // Clear session
    ref.read(sessionProvider.notifier).endSession();

    // Navigate to HistoryScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Calm':
        return '🧘';
      case 'Grounded':
        return '🌿';
      case 'Energized':
        return '⚡';
      case 'Sleepy':
        return '😴';
      default:
        return '🧘';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What is gently present with you right now?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Text(
                'Reflect on your experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Reflection Text Input
              Text(
                'Your Reflection',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reflectionController,
                maxLines: 6,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts and feelings from this session...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Mood Selector
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Mood buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['Calm', 'Grounded', 'Energized', 'Sleepy']
                          .map((mood) => GestureDetector(
                            onTap: () => setState(() => _selectedMood = mood),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _selectedMood == mood
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getMoodEmoji(mood),
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mood,
                                    style: Theme.of(context).textTheme.labelSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveReflection,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Save Reflection'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).endSession();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Skip'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
