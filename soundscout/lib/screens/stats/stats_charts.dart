import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart of average rating per genre (0-5 scale).
class GenreBarChart extends StatelessWidget {
  const GenreBarChart({super.key, required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return BarChart(
      BarChartData(
        maxY: 5,
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (int i = 0; i < entries.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: entries[i].value,
                width: 16,
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.primary,
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Text(entries[i].key, style: const TextStyle(fontSize: 10)),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

/// Bar chart of how many albums the user gave each star rating (1-5).
class DistributionChart extends StatelessWidget {
  const DistributionChart({super.key, required this.data});

  final Map<int, int> data;

  @override
  Widget build(BuildContext context) {
    final maxCount = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: (maxCount + 1).toDouble(),
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (int star = 1; star <= 5; star++)
            BarChartGroupData(x: star, barRods: [
              BarChartRodData(
                toY: (data[star] ?? 0).toDouble(),
                width: 22,
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}★'),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

/// Bar chart of albums logged per month, keys formatted as "YYYY-MM".
class TimelineChart extends StatelessWidget {
  const TimelineChart({super.key, required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList()..sort();
    final maxCount = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: (maxCount + 1).toDouble(),
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (int i = 0; i < keys.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (data[keys[i]] ?? 0).toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(keys[i].substring(2), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
