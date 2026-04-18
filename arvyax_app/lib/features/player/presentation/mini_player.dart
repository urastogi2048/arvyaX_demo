import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/session_provider.dart';
import '../../../data/models/session.dart';
import 'screens/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    
    if (session == null || session.status == SessionStatus.ended) {
      return const SizedBox.shrink();
    }
    
    final progress = session.totalSeconds > 0
        ? session.elapsedSeconds / session.totalSeconds
        : 0.0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(ambience: session.ambience),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.h,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Content row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.ambience.title,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${session.elapsedSeconds ~/ 60}:${(session.elapsedSeconds % 60).toString().padLeft(2, '0')} / ${session.totalSeconds ~/ 60}:00',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Play/Pause button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      session.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      if (session.isPlaying) {
                        ref.read(sessionProvider.notifier).pause();
                      } else {
                        ref.read(sessionProvider.notifier).resume();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}