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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
              ),
            ),
          ),
          // Player Controls
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Title
                Text(
                  session.ambience.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(session.elapsedSeconds),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      _formatTime(session.totalSeconds),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 44),

                // Play/Pause Button
                FloatingActionButton.large(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (session.isPlaying) {
                      ref.read(sessionProvider.notifier).pause();
                    } else {
                      ref.read(sessionProvider.notifier).resume();
                    }
                  },
                  child: Icon(
                    session.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 44),

                // End Session Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showEndSessionDialog(context, ref);
                    },
                    icon: const Icon(Icons.stop_circle_outlined, size: 20),
                    label: const Text('End Session'),
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
