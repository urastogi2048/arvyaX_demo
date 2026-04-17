import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/ambience_providers.dart';
import '../../../../core/providers/filter_provider.dart';
import '../../../../data/models/ambience.dart';
import 'details_screen.dart';

const List<String> tagOptions = ['Focus', 'Calm', 'Sleep', 'Reset'];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAmbiencesAsync = ref.watch(filteredAmbiencesProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArvyaX'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    ref.read(filterProvider.notifier).updateSearch(value);
                  },
                  leading: const Icon(Icons.search),
                  hintText: 'Search ambiences...',
                );
              },
              suggestionsBuilder: (BuildContext context,
                  SearchController controller) {
                return const [];
              },
            ),
          ),
          
          // Tag Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: filter.selectedTag == null,
                  onSelected: (_) {
                    ref.read(filterProvider.notifier).updateTag(null);
                  },
                ),
                ...tagOptions.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: filter.selectedTag == tag,
                    onSelected: (selected) {
                      ref.read(filterProvider.notifier).updateTag(
                            selected ? tag : null,
                          );
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Clear Filters Button (only show if filters are active)
          if (filter.searchText.isNotEmpty || filter.selectedTag != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).clearFilters();
                  },
                  child: const Text('Clear Filters'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Ambiences Grid
          Expanded(
            child: filteredAmbiencesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (ambiences) {
                // Empty state
                if (ambiences.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ambiences found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(filterProvider.notifier).clearFilters();
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: ambiences.length,
                  itemBuilder: (context, index) {
                    return AmbienanceCard(ambience: ambiences[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AmbienanceCard extends StatelessWidget {
  final Ambience ambience;

  const AmbienanceCard({
    super.key,
    required this.ambience,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(ambience: ambience),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ambience.title,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Chip(
                          label: Text(
                            ambience.tag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Text(
                        '${ambience.duration ~/ 60}m',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
