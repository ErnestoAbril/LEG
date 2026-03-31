import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_providers.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/error/failures.dart';

/// Demo widget showing how to use the error handling system
/// 
/// This widget demonstrates:
/// - Use case integration with Clean Architecture
/// - Professional error handling with user-friendly messages
/// - Riverpod state management with error states
/// - Error recovery and retry functionality
class ExpenseErrorHandlingDemo extends ConsumerStatefulWidget {
  const ExpenseErrorHandlingDemo({super.key});

  @override
  ConsumerState<ExpenseErrorHandlingDemo> createState() =>
      _ExpenseErrorHandlingDemoState();
}

class _ExpenseErrorHandlingDemoState extends ConsumerState<ExpenseErrorHandlingDemo> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Alimentación';
  Failure? _currentFailure;
  bool _isLoading = false;

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Servicios',
    'Otros',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    setState(() {
      _isLoading = true;
      _currentFailure = null;
    });

    try {
      // Parse amount
      final amount = double.tryParse(_amountController.text);
      if (amount == null) {
        setState(() {
          _currentFailure = const ValidationFailure(
            message: 'El monto debe ser un número válido'
          );
          _isLoading = false;
        });
        return;
      }

      // Create expense
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text,
        amount: amount,
        category: _selectedCategory,
        date: DateTime.now(),
      );

      // Use the add expense use case
      final addExpenseUseCase = ref.read(addExpenseUseCaseProvider);
      final failure = await addExpenseUseCase.execute(expense);

      if (failure != null) {
        setState(() {
          _currentFailure = failure;
          _isLoading = false;
        });
      } else {
        // Success - clear form and refresh expenses
        _clearForm();
        ref.read(expensesProvider.notifier).loadExpenses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💰 Gasto agregado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentFailure = const ServerFailure(
          message: 'Error inesperado al agregar el gasto'
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _currentFailure = null;
    });

    try {
      final getExpensesUseCase = ref.read(getExpensesUseCaseProvider);
      final result = await getExpensesUseCase.execute();

      if (result.isFailure && result.failure != null) {
        setState(() {
          _currentFailure = result.failure;
        });
      }
      // Success case is handled by the provider automatically
    } catch (e) {
      setState(() {
        _currentFailure = const ServerFailure(
          message: 'Error al cargar los gastos'
        );
      });
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _amountController.clear();
    _selectedCategory = _categories.first;
    setState(() {
      _currentFailure = null;
    });
  }

  void _retryOperation() {
    setState(() {
      _currentFailure = null;
    });
    _addExpense();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Demo: Manejo de Errores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
            tooltip: 'Recargar gastos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Sistema de Manejo de Errores',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este demo muestra Clean Architecture con manejo profesional de errores, '
                      'validación de negocio, reintentos automáticos y mensajes amigables.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Error display
            if (_currentFailure != null)
              ErrorDisplayWidget(
                error: _currentFailure!,
                onRetry: _retryOperation,
              ),

            const SizedBox(height: 16),

            // Add expense form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '➕ Agregar Nuevo Gasto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Ej: Almuerzo, Gasolina, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Amount field
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'COP',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _clearForm,
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addExpense,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('💰 Agregar Gasto'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expenses list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Lista de Gastos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    expensesAsync.when(
                      data: (expenses) {
                        if (expenses.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay gastos registrados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agrega tu primer gasto usando el formulario',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                                child: Text(
                                  expense.category[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                expense.description,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                '\$${expense.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => ErrorDisplayWidget(
                        error: ServerFailure(message: error.toString()),
                        onRetry: () => ref.read(expensesProvider.notifier).loadExpenses(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}