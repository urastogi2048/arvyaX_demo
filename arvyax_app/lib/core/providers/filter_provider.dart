import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/ambience.dart';
import 'ambience_providers.dart';
class FilterState {
  final String searchText;
  final String? selectedTag;

  FilterState({
    this.searchText = '',
    this.selectedTag,
  });

  FilterState copyWith({
    String? searchText,
    String? selectedTag,
  }) {
    return FilterState(
      searchText: searchText ?? this.searchText,
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void updateSearch(String text) {
    state = state.copyWith(searchText: text);
  }

  void updateTag(String? tag) {
    state = state.copyWith(selectedTag: tag);
  }

  void clearFilters() {
    state = FilterState();
  }
}
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
final filteredAmbiencesProvider =
    FutureProvider<List<Ambience>>((ref) async {
  final ambiences = await ref.watch(ambiencesProvider.future);
  final filter = ref.watch(filterProvider);
  var results = ambiences;
  if (filter.searchText.isNotEmpty) {
    results = results
        .where((a) =>
            a.title.toLowerCase().contains(filter.searchText.toLowerCase()) ||
            a.description.toLowerCase().contains(filter.searchText.toLowerCase()))
        .toList();
  }
  if (filter.selectedTag != null) {
    results = results.where((a) => a.tag == filter.selectedTag).toList();
  }

  return results;
});
