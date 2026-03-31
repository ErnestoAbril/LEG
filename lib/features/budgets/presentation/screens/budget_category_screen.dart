import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_providers.dart';
import '../../domain/entities/budget.dart';
import '../../../../shared/utils/format_utils.dart';

class BudgetCategoryScreen extends ConsumerStatefulWidget {
  final String budgetId;
  
  const BudgetCategoryScreen({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<BudgetCategoryScreen> createState() => _BudgetCategoryScreenState();
}

class _BudgetCategoryScreenState extends ConsumerState<BudgetCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías del Presupuesto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
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
                onPressed: () => ref.invalidate(budgetsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (budgets) {
          final budget = budgets.firstWhere(
            (b) => b.id == widget.budgetId,
            orElse: () => Budget(
              id: '',
              name: '',
              categories: {},
              period: BudgetPeriod.monthly,
              createdAt: DateTime.now(),
            ),
          );

          if (budget.id.isEmpty) {
            return const Center(
              child: Text(
                'Presupuesto no encontrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          if (budget.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined, 
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay categorías en este presupuesto',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Categoría'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budget.categories.length,
            itemBuilder: (context, index) {
              final entry = budget.categories.entries.elementAt(index);
              return _CategoryCard(
                categoryName: entry.key,
                amount: entry.value,
                onEdit: () => _showEditCategoryDialog(context, entry.key, entry.value),
                onDelete: () => _deleteCategory(context, entry.key),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    String categoryName = '';
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => categoryName = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Monto presupuestado',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryName.isNotEmpty && amount > 0) {
                _addCategory(categoryName, amount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, String categoryName, double currentAmount) {
    double amount = currentAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: $categoryName'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Monto presupuestado',
            border: OutlineInputBorder(),
            prefixText: '\$ ',
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: currentAmount.toString()),
          onChanged: (value) {
            amount = double.tryParse(value) ?? currentAmount;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amount > 0) {
                _updateCategory(categoryName, amount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addCategory(String categoryName, double amount) {
    // Find the budget and update its categories
    final budgets = ref.read(budgetsProvider).value ?? [];
    final budgetIndex = budgets.indexWhere((b) => b.id == widget.budgetId);
    
    if (budgetIndex != -1) {
      final budget = budgets[budgetIndex];
      final updatedCategories = Map<String, double>.from(budget.categories);
      updatedCategories[categoryName] = amount;
      
      final updatedBudget = budget.copyWith(categories: updatedCategories);
      ref.read(budgetsProvider.notifier).updateBudget(updatedBudget);
    }
  }

  void _updateCategory(String categoryName, double amount) {
    final budgets = ref.read(budgetsProvider).value ?? [];
    final budgetIndex = budgets.indexWhere((b) => b.id == widget.budgetId);
    
    if (budgetIndex != -1) {
      final budget = budgets[budgetIndex];
      final updatedCategories = Map<String, double>.from(budget.categories);
      updatedCategories[categoryName] = amount;
      
      final updatedBudget = budget.copyWith(categories: updatedCategories);
      ref.read(budgetsProvider.notifier).updateBudget(updatedBudget);
    }
  }

  void _deleteCategory(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la categoría "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final budgets = ref.read(budgetsProvider).value ?? [];
              final budgetIndex = budgets.indexWhere((b) => b.id == widget.budgetId);
              
              if (budgetIndex != -1) {
                final budget = budgets[budgetIndex];
                final updatedCategories = Map<String, double>.from(budget.categories);
                updatedCategories.remove(categoryName);
                
                final updatedBudget = budget.copyWith(categories: updatedCategories);
                ref.read(budgetsProvider.notifier).updateBudget(updatedBudget);
              }
              
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final double amount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.categoryName,
    required this.amount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.category),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Presupuestado: ${formatCurrency(amount)}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
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
      ),
    );
  }
}