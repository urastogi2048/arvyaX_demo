import 'package:arvyax_app/data/models/ambience.dart';
import 'package:arvyax_app/data/models/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class SessionNotifier extends StateNotifier<SessionModel?> {
  Timer? _timer;
  late AudioPlayer _audioPlayer;

  SessionNotifier() : super(null) {
    _audioPlayer = AudioPlayer();
    _loadSessionFromStorage();
  }

  Future<void> _loadSessionFromStorage() async {
    try {
      final box = Hive.box<dynamic>('sessions');
      final sessionData = box.get('currentSession');
      
      if (sessionData != null) {
        final now = DateTime.now();
        final startedAt = DateTime.parse(sessionData['startedAt']);
        final timePassed = now.difference(startedAt).inSeconds;
        final elapsedSeconds = sessionData['elapsedSeconds'] + timePassed;
        final totalSeconds = sessionData['totalSeconds'];
        
        if (elapsedSeconds < totalSeconds) {
          state = SessionModel(
            id: sessionData['id'],
            ambience: _getAmbienceFromStorage(sessionData['ambienceId']),
            elapsedSeconds: elapsedSeconds,
            totalSeconds: totalSeconds,
            isPlaying: sessionData['isPlaying'] ?? true,
            status: SessionStatus.active,
            startedAt: startedAt,
            completedAt: null,
          );
          
          if (state!.isPlaying) {
            await _startAudio(_getAmbienceFromStorage(sessionData['ambienceId']));
            _startTimer();
          }
        } else {
          await box.delete('currentSession');
          state = null;
        }
      }
    } catch (e) {
      print('Error loading session from storage: $e');
      try {
        final box = Hive.box<dynamic>('sessions');
        await box.delete('currentSession');
      } catch (_) {}
      state = null;
    }
  }

  Ambience _getAmbienceFromStorage(String ambienceId) {
    final ambienceMap = {
      'forest_focus': Ambience(
        id: 'forest_focus',
        title: 'Forest Focus',
        tag: 'Focus',
        duration: 180,
        description: 'Deep woods with gentle birdsong.',
        image: 'assets/images/forest_focus.jpg',
        audio: 'assets/audio/forest_focus.mp3',
        sensoryTags: ['Breeze', 'Birdsong', 'Mist', 'Warm Light'],
      ),
      'ocean_calm': Ambience(
        id: 'ocean_calm',
        title: 'Ocean Calm',
        tag: 'Calm',
        duration: 180,
        description: 'Soft waves lapping on a quiet shore.',
        image: 'assets/images/ocean_calm.jpg',
        audio: 'assets/audio/ocean_calm.mp3',
        sensoryTags: ['Soft Rain', 'Breeze', 'Sand', 'Horizon'],
      ),
      'rain_sleep': Ambience(
        id: 'rain_sleep',
        title: 'Rainy Night',
        tag: 'Sleep',
        duration: 180,
        description: 'Gentle rain on a cozy evening.',
        image: 'assets/images/rainy_night.jpg',
        audio: 'assets/audio/rainy_night.mp3',
        sensoryTags: ['Soft Rain', 'Thunder', 'Cozy', 'Darkness'],
      ),
      'mountain_reset': Ambience(
        id: 'mountain_reset',
        title: 'Mountain Reset',
        tag: 'Reset',
        duration: 120,
        description: 'High altitude serenity.',
        image: 'assets/images/mountain_reset.jpg',
        audio: 'assets/audio/mountain_reset.mp3',
        sensoryTags: ['Wind', 'Silence', 'Echo', 'Clarity'],
      ),
      'garden_focus': Ambience(
        id: 'garden_focus',
        title: 'Garden Focus',
        tag: 'Focus',
        duration: 150,
        description: 'Blooming garden with soft ambience.',
        image: 'assets/images/garden_focus.jpg',
        audio: 'assets/audio/garden_focus.mp3',
        sensoryTags: ['Breeze', 'Birdsong', 'Flowers', 'Warm Light'],
      ),
      'meditation_bells': Ambience(
        id: 'meditation_bells',
        title: 'Meditation Bells',
        tag: 'Calm',
        duration: 180,
        description: 'Gentle bells for meditation.',
        image: 'assets/images/meditation_bells.jpg',
        audio: 'assets/audio/meditation_bells.mp3',
        sensoryTags: ['Bells', 'Silence', 'Peace', 'Stillness'],
      ),
    };
    return ambienceMap[ambienceId] ?? ambienceMap['forest_focus']!;
  }

  void startSession(Ambience ambience) {
    _timer?.cancel();
    _audioPlayer.stop();
    
    try {
      final box = Hive.box<dynamic>('sessions');
      box.delete('currentSession');
    } catch (e) {
      print('Error clearing old session: $e');
    }
    
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
    
    _saveSessionToStorage();
    _startAudio(ambience);
    _startTimer();
  }

  Future<void> _saveSessionToStorage() async {
    if (state != null) {
      try {
        final box = Hive.box<dynamic>('sessions');
        await box.put('currentSession', {
          'id': state!.id,
          'ambienceId': state!.ambience.id,
          'elapsedSeconds': state!.elapsedSeconds,
          'totalSeconds': state!.totalSeconds,
          'isPlaying': state!.isPlaying,
          'startedAt': state!.startedAt.toIso8601String(),
        });
      } catch (e) {
        print('Error saving session to storage: $e');
      }
    }
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
        _saveSessionToStorage();
        
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
      _saveSessionToStorage();
    }
  }

  void resume() {
    if (state != null) {
      _audioPlayer.play();
      state = state!.copyWith(isPlaying: true, status: SessionStatus.active);
      _saveSessionToStorage();
    }
  }

  void updateElapsed(int seconds) {
    if (state != null) {
      state = state!.copyWith(elapsedSeconds: seconds);
      _saveSessionToStorage();
    }
  }

  void endSession() {
    if (state != null) {
      _timer?.cancel();
      _audioPlayer.stop();
      state = state!.copyWith(status: SessionStatus.ended, completedAt: DateTime.now());
      try {
        final box = Hive.box<dynamic>('sessions');
        box.delete('currentSession');
      } catch (e) {
        print('Error deleting session from storage: $e');
      }
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