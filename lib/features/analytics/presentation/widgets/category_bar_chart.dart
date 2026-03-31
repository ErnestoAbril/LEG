import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/analytics_data.dart';
import '../../../../shared/utils/format_utils.dart';

/// Bar chart widget for displaying category analytics
class CategoryBarChart extends StatelessWidget {
  final List<CategoryAnalytics> categoryData;
  final Color? primaryColor;
  final double height;

  const CategoryBarChart({
    super.key,
    required this.categoryData,
    this.primaryColor,
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

    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.primaryColor;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: categoryData.isNotEmpty 
                ? categoryData.first.totalAmount * 1.2 
                : 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex < categoryData.length) {
                    final category = categoryData[groupIndex];
                    return BarTooltipItem(
                      '${category.categoryName}\n${formatCurrency(category.totalAmount)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < categoryData.length) {
                      final categoryName = categoryData[index].categoryName;
                      // Truncate long category names
                      final displayName = categoryName.length > 8 
                          ? '${categoryName.substring(0, 8)}...'
                          : categoryName;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      formatCurrency(value),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                  reservedSize: 60,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: _createBarGroups(effectivePrimaryColor),
            gridData: const FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(Color primaryColor) {
    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryAnalytics = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoryAnalytics.totalAmount,
            color: primaryColor.withValues(alpha: 0.8),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}