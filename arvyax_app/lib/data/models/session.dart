import 'package:arvyax_app/data/models/ambience.dart';
enum SessionStatus {active, paused, completed, ended}
class SessionModel {
  final String id;
  final Ambience ambience;
  final int elapsedseconds;
  final int totalseconds;
  final bool isplaying;
  final SessionStatus status;
  final DateTime startedat;
  final DateTime? completedat;


  SessionModel({
    required this.id,
    required this.ambience,
    required this.elapsedseconds,
    required this.totalseconds,
    required this.isplaying,
    required this.status,
    required this.startedat,
    this.completedat,
  });
  SessionModel copyWith ({
    String? id,
    Ambience? ambience,
    int? elapsedseconds,
    int? totalseconds,
    bool? isplaying,
    SessionStatus? status,
    DateTime? startedat,
    DateTime? completedat,
  }) {
    return SessionModel(
      id: id ?? this.id,
      ambience: ambience ?? this.ambience,
      elapsedseconds: elapsedseconds ?? this.elapsedseconds,
      totalseconds: totalseconds ?? this.totalseconds,
      isplaying: isplaying ?? this.isplaying,
      status: status ?? this.status,
      startedat: startedat ?? this.startedat,
      completedat: completedat ?? this.completedat,
    );
  }
}