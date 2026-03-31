import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/analytics_data.dart';
import '../../../../shared/utils/format_utils.dart';

/// Pie chart widget for displaying category analytics
class CategoryPieChart extends StatelessWidget {
  final List<CategoryAnalytics> categoryData;
  final double radius;
  final bool showLabels;
  final double height;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
    this.radius = 60,
    this.showLabels = true,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No hay datos para mostrar',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                // Optional: Handle touch events
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: _createPieSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryAnalytics = entry.value;
      final color = colors[index % colors.length];
      
      final isLargeSection = categoryAnalytics.percentage > 15;
      
      return PieChartSectionData(
        color: color,
        value: categoryAnalytics.totalAmount,
        title: showLabels && isLargeSection 
            ? '${categoryAnalytics.percentage.toStringAsFixed(1)}%'
            : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}

/// Legend widget for the pie chart
class PieChartLegend extends StatelessWidget {
  final List<CategoryAnalytics> categoryData;
  final int maxItems;

  const PieChartLegend({
    super.key,
    required this.categoryData,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    final itemsToShow = categoryData.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...itemsToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryAnalytics = entry.value;
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoryAnalytics.categoryName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  formatCurrency(categoryAnalytics.totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${categoryAnalytics.percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }),
        if (categoryData.length > maxItems) ...[
          const SizedBox(height: 4),
          Text(
            '... y ${categoryData.length - maxItems} más',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}