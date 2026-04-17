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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 30,height: 30),
            SizedBox(width : 10),
            const Text('ArvyaX'),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilterChip(
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: filter.selectedTag == null
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            filter.selectedTag == null ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: filter.selectedTag == null,
                    onSelected: (isSelected) {
                      // Always clear filters when All is clicked, regardless of state
                      ref.read(filterProvider.notifier).updateTag(null);
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  ...tagOptions.map((tag) {
                    final isSelected = filter.selectedTag == tag;
                    return FilterChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        // Only allow selecting, not deselecting via the chip
                        if (selected) {
                          ref.read(filterProvider.notifier).updateTag(tag);
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(context).colorScheme.primary,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Clear Filters Button (only show if filters are active)
            if (filter.searchText.isNotEmpty || filter.selectedTag != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(filterProvider.notifier).clearFilters();
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear Filters'),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            // Ambiences Grid
            filteredAmbiencesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Error: $error'),
              ),
              data: (ambiences) {
                // Empty state
                if (ambiences.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No ambiences found',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(filterProvider.notifier).clearFilters();
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: ambiences.length,
                    itemBuilder: (context, index) {
                      return AmbienanceCard(ambience: ambiences[index]);
                    },
                  ),
                );
              },
            ),
          ],
        ),
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
            // Placeholder image with gradient overlay
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ambience.title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ambience.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        '${ambience.duration ~/ 60}m',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
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
