import 'package:arvyax_app/data/models/ambience.dart';
import 'package:arvyax_app/data/models/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';

class SessionNotifier extends StateNotifier<SessionModel?> {
  SessionNotifier() : super(null);
  Timer? _timer;

  void startSession(Ambience ambience) {
    // Cancel existing timer
    _timer?.cancel();
    
    state = SessionModel(
      id: DateTime.now().toString(),
      ambience: ambience,
      elapsedSeconds: 0,
      totalSeconds: ambience.duration,
      isPlaying: true,
      status: SessionStatus.active,
      startedAt: DateTime.now(),
      completedAt: null,
    );
    
    // Start timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (state != null && state!.isPlaying) {
        final newElapsed = state!.elapsedSeconds + 1;
        state = state!.copyWith(elapsedSeconds: newElapsed);
        
        // Auto-complete when time is up
        if (newElapsed >= state!.totalSeconds) {
          _timer?.cancel();
          endSession();
        }
      }
    });
  }

  void pause() {
    if (state != null) {
      state = state!.copyWith(isPlaying: false, status: SessionStatus.paused);
    }
  }

  void resume() {
    if (state != null) {
      state = state!.copyWith(isPlaying: true, status: SessionStatus.active);
    }
  }

  void updateElapsed(int seconds) {
    if (state != null) {
      state = state!.copyWith(elapsedSeconds: seconds);
    }
  }

  void endSession() {
    if (state != null) {
      _timer?.cancel();
      state = state!.copyWith(status: SessionStatus.ended, completedAt: DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


final sessionProvider = StateNotifierProvider<SessionNotifier, SessionModel?>((ref) {
  return SessionNotifier();
});