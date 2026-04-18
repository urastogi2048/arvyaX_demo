import 'package:arvyax_app/data/models/ambience.dart';

enum SessionStatus { active, paused, completed, ended }

class SessionModel {
  final String id;
  final Ambience ambience;
  final int elapsedSeconds;
  final int totalSeconds;
  final bool isPlaying;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;

  SessionModel({
    required this.id,
    required this.ambience,
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.isPlaying,
    required this.status,
    required this.startedAt,
    this.completedAt,
  });

  SessionModel copyWith({
    String? id,
    Ambience? ambience,
    int? elapsedSeconds,
    int? totalSeconds,
    bool? isPlaying,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      ambience: ambience ?? this.ambience,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}