import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_providers.dart';
import '../../domain/entities/budget.dart';
import '../../../../shared/utils/format_utils.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final activeBudgetAsync = ref.watch(activeBudgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBudgetDialog(context, ref),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(budgetsProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (budgets) {
          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, 
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay presupuestos creados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateBudgetDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Presupuesto'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetsProvider);
              ref.invalidate(activeBudgetProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return _BudgetCard(
                  budget: budget,
                  isActive: activeBudgetAsync.value?.id == budget.id,
                  onTap: () => _showBudgetDetails(context, ref, budget),
                  onSetActive: () => _setActiveBudget(ref, budget.id),
                  onEdit: () => _showEditBudgetDialog(context, ref, budget),
                  onDelete: () => _deleteBudget(context, ref, budget),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateBudgetDialog(BuildContext context, WidgetRef ref) {
    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Presupuesto ${DateTime.now().day}/${DateTime.now().month}',
      categories: {'Comida': 500.0, 'Transporte': 200.0},
      period: BudgetPeriod.monthly,
      createdAt: DateTime.now(),
    );
    
    ref.read(budgetsProvider.notifier).addBudget(budget);
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, Budget budget) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edición disponible próximamente')),
    );
  }

  void _showBudgetDetails(BuildContext context, WidgetRef ref, Budget budget) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalles de: ${budget.name}')),
    );
  }

  void _setActiveBudget(WidgetRef ref, String budgetId) {
    ref.read(budgetsProvider.notifier).setActiveBudget(budgetId);
    ref.read(activeBudgetProvider.notifier).setActiveBudget(budgetId);
  }

  void _deleteBudget(BuildContext context, WidgetRef ref, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el presupuesto "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(budgetsProvider.notifier).deleteBudget(budget.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.isActive,
    required this.onTap,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              budget.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Activo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${budget.period.nameLabel} • ${formatCurrency(budget.totalAmount)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'activate':
                          onSetActive();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isActive)
                        const PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 8),
                              Text('Activar'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (budget.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  budget.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '${budget.categories.length} categorías',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}