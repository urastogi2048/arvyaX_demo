import 'package:flutter/material.dart';
import '../../../../data/models/ambience.dart';
import '../../../player/presentation/screens/player_screen.dart';

class DetailsScreen extends StatelessWidget {
  final Ambience ambience;

  const DetailsScreen({
    super.key,
    required this.ambience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image with gradient overlay
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Tag + Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ambience.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ambience.tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${ambience.duration ~/ 60}m',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ambience.duration % 60}s',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ambience.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Sensory Tags
                  Text(
                    'Sensory Recipe',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ambience.sensoryTags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 40),
                  
                  // Start Session Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlayerScreen(ambience: ambience),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline, size: 20),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Start Session'),
                      ),
                    ),
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
