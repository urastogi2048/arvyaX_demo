import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

final journalRepositoryProvider = Provider((ref) {
  return JournalRepository();
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final JournalRepository repository;

  JournalNotifier(this.repository) : super([]) {
    _loadEntries();
  }

  // Load entries from Hive on startup
  void _loadEntries() async {
    await repository.initBox();
    state = repository.getAllEntries();
  }

  // Add entry to Hive + update state
  void addEntry(JournalEntry entry) async {
    await repository.addEntry(entry);
    state = [...state, entry];
  }

  void removeEntry(String entryId) async {
    await repository.deleteEntry(entryId);
    state = state.where((entry) => entry.id != entryId).toList();
  }

  void clearAll() {
    state = [];
  }

  List<JournalEntry> getBySessionId(String sessionId) {
    return state.where((entry) => entry.sessionId == sessionId).toList();
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalNotifier(repository);
});
