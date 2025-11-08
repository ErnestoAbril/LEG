import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/chart_config.dart';
import '../providers/analytics_providers.dart';
import 'category_bar_chart.dart';
import 'category_pie_chart.dart';

/// Combined chart widget that displays either bar or pie chart based on user preference
class CategoryAnalyticsChart extends ConsumerWidget {
  final List<CategoryAnalytics> categoryData;
  final double height;
  final bool showChartTypeToggle;
  final bool showLegend;

  const CategoryAnalyticsChart({
    super.key,
    required this.categoryData,
    this.height = 300,
    this.showChartTypeToggle = true,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartTypeAsync = ref.watch(chartTypeProvider);

    return chartTypeAsync.when(
      loading: () => SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Error al cargar el gráfico',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(chartTypeProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (chartType) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showChartTypeToggle) _buildChartTypeHeader(context, ref, chartType),
          _buildChart(chartType),
          if (showLegend && chartType == ChartType.pie) ...[
            const SizedBox(height: 16),
            PieChartLegend(categoryData: categoryData),
          ],
        ],
      ),
    );
  }

  Widget _buildChartTypeHeader(BuildContext context, WidgetRef ref, ChartType currentType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gastos por Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                'Tipo de gráfico:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<ChartType>(
                segments: const [
                  ButtonSegment<ChartType>(
                    value: ChartType.bar,
                    label: Text('Barras'),
                    icon: Icon(Icons.bar_chart),
                  ),
                  ButtonSegment<ChartType>(
                    value: ChartType.pie,
                    label: Text('Pastel'),
                    icon: Icon(Icons.pie_chart),
                  ),
                ],
                selected: {currentType},
                onSelectionChanged: (Set<ChartType> newSelection) {
                  if (newSelection.isNotEmpty) {
                    ref.read(chartTypeProvider.notifier).setChartType(newSelection.first);
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => ref.read(chartTypeProvider.notifier).toggleChartType(),
                icon: Icon(
                  currentType == ChartType.bar ? Icons.pie_chart : Icons.bar_chart,
                ),
                tooltip: 'Cambiar tipo de gráfico',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ChartType chartType) {
    if (categoryData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay gastos para mostrar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Agrega algunos gastos para ver el análisis',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    switch (chartType) {
      case ChartType.bar:
        return CategoryBarChart(
          categoryData: categoryData,
          height: height,
        );
      case ChartType.pie:
        return CategoryPieChart(
          categoryData: categoryData,
          height: height,
        );
    }
  }
}

/// Simple analytics summary card
class AnalyticsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const AnalyticsSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: effectiveColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}