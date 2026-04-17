import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ambience.dart';
import '../../data/repositories/ambienance_repository.dart';

final ambianceRepositoryProvider = Provider((ref) {
  return AmbienanceRepository();
});

final ambiencesProvider = FutureProvider<List<Ambience>>((ref) async {
  final repository = ref.watch(ambianceRepositoryProvider);
  return repository.loadAmbiences();
});
