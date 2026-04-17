import 'package:arvyax_app/data/models/ambience.dart';
import 'package:arvyax_app/data/models/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SessionNotifier extends StateNotifier<SessionModel?> {
  SessionNotifier() : super(null);

  void startSession(Ambience ambience) {
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
      state = state!.copyWith(status: SessionStatus.ended, completedAt: DateTime.now());
    }
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionModel?>((ref) {
  return SessionNotifier();
});