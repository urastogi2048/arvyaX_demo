import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/journal_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

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

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'Calm':
        return 'Calm';
      case 'Grounded':
        return 'Grounded';
      case 'Energized':
        return 'Energized';
      case 'Sleepy':
        return 'Sleepy';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflection History'),
        elevation: 0,
      ),
      body: entries.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'No reflections yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete a session and share your thoughts',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Start a Session'),
                ),
              ],
            ),
          )
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...entries.asMap().entries.map((entry) {
                    final journalEntry = entry.value;
                    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Date + Mood
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(journalEntry.createdAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _getMoodEmoji(journalEntry.mood),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        _getMoodLabel(journalEntry.mood),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Reflection Text
                              Text(
                                journalEntry.reflection,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  // Back to Home Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
    );
  }
}
