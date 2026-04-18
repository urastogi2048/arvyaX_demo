import 'package:hive/hive.dart';
part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String sessionId;
  
  @HiveField(2)
  final String reflection;
  
  @HiveField(3)
  final String mood;
  
  @HiveField(4)
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.sessionId,
    required this.reflection,
    required this.mood,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'reflection': reflection,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      reflection: map['reflection'] as String,
      mood: map['mood'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
  JournalEntry copyWith({
    String? id,
    String? sessionId,
    String? reflection,
    String? mood,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      reflection: reflection ?? this.reflection,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
