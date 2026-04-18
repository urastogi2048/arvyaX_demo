import 'package:arvyax_app/data/models/ambience.dart';
import 'package:arvyax_app/data/models/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class SessionNotifier extends StateNotifier<SessionModel?> {
  Timer? _timer;
  late AudioPlayer _audioPlayer;

  SessionNotifier() : super(null) {
    _audioPlayer = AudioPlayer();
  }

  void startSession(Ambience ambience) {
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
    
    _startAudio(ambience);
    _startTimer();
  }

  Future<void> _startAudio(Ambience ambience) async {
    try {
      await _audioPlayer.setAsset(ambience.audio);
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.play();
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (state != null && state!.isPlaying) {
        final newElapsed = state!.elapsedSeconds + 1;
        state = state!.copyWith(elapsedSeconds: newElapsed);
        
        if (newElapsed >= state!.totalSeconds) {
          _timer?.cancel();
          endSession();
        }
      }
    });
  }

  void pause() {
    if (state != null) {
      _audioPlayer.pause();
      state = state!.copyWith(isPlaying: false, status: SessionStatus.paused);
    }
  }

  void resume() {
    if (state != null) {
      _audioPlayer.play();
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
      _audioPlayer.stop();
      state = state!.copyWith(status: SessionStatus.ended, completedAt: DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}


final sessionProvider = StateNotifierProvider<SessionNotifier, SessionModel?>((ref) {
  return SessionNotifier();
});