import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../data/models/ambience.dart';
import '../../../../data/models/session.dart';
import '../../../journal/presentation/screens/journal_screen.dart';
import 'package:simple_animations/simple_animations.dart';
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
  bool _hasNavigated = false;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    
    if (session == null || session.ambience.id != widget.ambience.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionProvider.notifier).startSession(widget.ambience);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    // Track when a new session is created (with active status)
    if (session != null && session.status == SessionStatus.active && _currentSessionId != session.id) {
      _currentSessionId = session.id;
      _hasNavigated = false; // Reset navigation flag for new session
    }

    // Auto-navigate to JournalScreen only when THIS session ends
    if (session != null && 
        session.status == SessionStatus.ended && 
        !_hasNavigated &&
        _currentSessionId == session.id) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const JournalScreen()),
          );
        }
      });
    }

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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full-screen background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(session.ambience.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Fallback if image not found
                },
              ),
            ),
            child: PlayAnimationBuilder<double>(
              tween: Tween(begin: 0.15, end: 0.35),
              duration: const Duration(seconds: 4),
             // repeat: true,
              curve: Curves.easeInOut,
              builder: (context, opacity, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(opacity),
                        Colors.black.withOpacity(opacity + 0.15),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Content overlay
          Column(
            children: [
              const SizedBox(height: 80), // Space for AppBar
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          session.ambience.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(session.elapsedSeconds),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTime(session.totalSeconds),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 44),
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
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showEndSessionDialog(context, ref);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                            ),
                            icon: const Icon(Icons.stop_circle_outlined, size: 20, color: Colors.white),
                            label: const Text(
                              'End Session',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            onPressed: () async {
              //await _audioPlayer.stop();
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
