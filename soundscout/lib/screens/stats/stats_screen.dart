import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_status.dart';
import '../../providers/library_provider.dart';
import '../../widgets/state_views.dart';
import 'stats_charts.dart';

/// Data visualization over the user's own library — the app's "beyond
/// create-and-display" / advanced feature. Everything here is computed
/// locally from the SQLite-backed LibraryProvider, no network calls.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          if (library.status == LoadStatus.loading || library.status == LoadStatus.idle) {
            return const LoadingIndicator();
          }
          if (library.entries.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              message: 'Rate a few albums to see your listening stats here.',
            );
          }

          final avgByGenre = library.avgRatingByGenre;
          final distribution = library.ratingDistribution;
          final perMonth = library.entriesPerMonth;
          final totalRating = library.entries.fold<int>(0, (sum, e) => sum + e.rating);
          final overallAverage = totalRating / library.entries.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Summary', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Total albums rated: ${library.entries.length}'),
                      Text('Genres explored: ${avgByGenre.length}'),
                      Text('Overall average rating: ${overallAverage.toStringAsFixed(1)} / 5'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Average Rating by Genre', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 220, child: GenreBarChart(data: avgByGenre)),
              const SizedBox(height: 32),
              Text('Rating Distribution', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 200, child: DistributionChart(data: distribution)),
              const SizedBox(height: 32),
              Text('Albums Logged Over Time', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 200, child: TimelineChart(data: perMonth)),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
