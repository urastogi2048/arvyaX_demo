import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../data/models/ambience.dart';
import '../../../../data/models/session.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Ambience ambience;

  const PlayerScreen({
    super.key,
    required this.ambience,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Start session when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).startSession(widget.ambience);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = session.totalSeconds > 0
        ? session.elapsedSeconds / session.totalSeconds
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Image
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceDim,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
          // Player Controls
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Title
                Text(
                  session.ambience.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                ),
                const SizedBox(height: 16),

                // Time Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(session.elapsedSeconds),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _formatTime(session.totalSeconds),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Play/Pause Button
                FloatingActionButton.large(
                  onPressed: () {
                    if (session.isPlaying) {
                      ref.read(sessionProvider.notifier).pause();
                    } else {
                      ref.read(sessionProvider.notifier).resume();
                    }
                  },
                  child: Icon(
                    session.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 32),

                // End Session Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showEndSessionDialog(context, ref);
                    },
                    child: const Text('End Session'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(sessionProvider.notifier).endSession();
              Navigator.pop(context);
              Navigator.pop(context); // Back to details
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}
