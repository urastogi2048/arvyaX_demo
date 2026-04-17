import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _selectedMood = '3'; // Default to neutral (3/5)

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
      case '1':
        return '😔';
      case '2':
        return '😕';
      case '3':
        return '😐';
      case '4':
        return '🙂';
      case '5':
        return '😊';
      default:
        return '😐';
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'How was your session?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Share your thoughts and feelings',
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
                  hintText: 'What did you experience? How do you feel?',
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
                    // Mood slider with emoji
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['1', '2', '3', '4', '5']
                          .map((mood) => GestureDetector(
                            onTap: () => setState(() => _selectedMood = mood),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedMood == mood
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getMoodEmoji(mood),
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['Very Bad', 'Bad', 'Okay', 'Good', 'Great']
                          .map((label) => Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall,
                            textAlign: TextAlign.center,
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
