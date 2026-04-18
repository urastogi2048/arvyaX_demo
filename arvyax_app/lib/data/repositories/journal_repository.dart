import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  static const String box='journals';
  Future <void> initBox() async{
    if(!Hive.isBoxOpen(box)) {
      await Hive.openBox<JournalEntry>(box);
    }
  }
  List<JournalEntry> getAllEntries() {
    final box1=Hive.box<JournalEntry>(box);
    return box1.values.toList().reversed.toList();


  }
  Future<void>addEntry(JournalEntry entry) async{
    final box1=Hive.box<JournalEntry>(box);
    await box1.put(entry.id,entry);
  }
  Future<void> deleteEntry(String entryId) async {
    final box1 = Hive.box<JournalEntry>(box);
    await box1.delete(entryId);
  }
  List<JournalEntry> getBySessionId(String sessionId) {
    final box1=Hive.box<JournalEntry>(box);
     return box1.values
            .where((entry) => entry.sessionId==sessionId)
            .toList();
            
  }
}