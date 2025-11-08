import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/category_analytics_chart.dart';
import '../../../../shared/utils/format_utils.dart';

/// Main analytics screen displaying comprehensive expense analytics
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(analyticsDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(analyticsDashboardProvider);
              ref.invalidate(chartTypeProvider);
            },
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los análisis',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $error',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(analyticsDashboardProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (dashboard) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              _buildSummarySection(dashboard),
              const SizedBox(height: 24),
              
              // Category analytics chart
              _buildCategoryChartSection(dashboard),
              const SizedBox(height: 24),
              
              // Top categories section
              _buildTopCategoriesSection(dashboard),
              const SizedBox(height: 24),
              
              // Monthly trends section
              _buildMonthlyTrendsSection(dashboard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(AnalyticsDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Mes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            AnalyticsSummaryCard(
              title: 'Total del Mes',
              value: formatCurrency(dashboard.currentMonth.totalAmount),
              subtitle: '${dashboard.currentMonth.totalExpenses} gastos',
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            AnalyticsSummaryCard(
              title: 'Promedio por Gasto',
              value: formatCurrency(dashboard.currentMonth.averageExpenseAmount),
              subtitle: 'Gasto promedio',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            AnalyticsSummaryCard(
              title: 'Esta Semana',
              value: formatCurrency(dashboard.currentWeek.totalAmount),
              subtitle: '${dashboard.currentWeek.totalExpenses} gastos',
              icon: Icons.calendar_today,
              color: Colors.orange,
            ),
            AnalyticsSummaryCard(
              title: 'Categoría Principal',
              value: dashboard.currentMonth.topCategory.isNotEmpty 
                  ? dashboard.currentMonth.topCategory 
                  : 'N/A',
              subtitle: 'Mayor gasto',
              icon: Icons.category,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChartSection(AnalyticsDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryAnalyticsChart(
          categoryData: dashboard.currentMonth.categoryBreakdown,
          height: 300,
          showChartTypeToggle: true,
          showLegend: true,
        ),
      ],
    );
  }

  Widget _buildTopCategoriesSection(AnalyticsDashboard dashboard) {
    final topCategories = dashboard.topCategories.take(5).toList();
    
    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 5 Categorías (Últimos 30 días)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topCategories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = topCategories[index];
              final rank = index + 1;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(index),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  category.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('${category.expenseCount} gastos'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(category.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${category.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendsSection(AnalyticsDashboard dashboard) {
    if (dashboard.monthlyTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tendencia Mensual',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos ${dashboard.monthlyTrends.length} meses',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      color: Colors.green[600],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dashboard.monthlyTrends.length,
                    itemBuilder: (context, index) {
                      final trend = dashboard.monthlyTrends[index];
                      final month = _getMonthName(trend.startDate.month);
                      
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  formatCurrency(trend.totalAmount),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              month,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
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
    return colors[index % colors.length];
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}