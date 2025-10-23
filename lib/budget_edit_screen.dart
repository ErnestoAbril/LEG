import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/presupuesto_unificado.dart';
import 'helpers/presupuestos_helpers.dart';
import 'format_utils.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

class BudgetEditScreen extends StatefulWidget {
  final PresupuestoUnificado presupuesto;
  final int presupuestoIndex;

  const BudgetEditScreen({
    super.key,
    required this.presupuesto,
    required this.presupuestoIndex,
  });

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  late TextEditingController _nameController;
  late String _selectedType;
  late Map<String, double> _categorias;
  Map<String, double> _gastado = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.presupuesto.nombre);
    _selectedType = widget.presupuesto.tipo;
    _categorias = Map<String, double>.from(widget.presupuesto.categorias);
    _loadGastado();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadGastado() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx = prefs.getInt('presupuesto_unificado_seleccionado');
      if (idx != null) {
        final gastos = GastoRepository.obtenerGastosPorPresupuesto(idx);
        final Map<String, double> sum = {};
        for (var g in gastos) {
          final v = g.montoCents != null
              ? g.montoCents! / 100.0
              : (parseMonto(g.monto) ?? 0);
          sum[g.categoria] = (sum[g.categoria] ?? 0) + v;
        }
        _gastado = sum;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveBudget() async {
    final updatedBudget = PresupuestoUnificado(
      id: widget.presupuesto.id,
      nombre: _nameController.text.trim(),
      tipo: _selectedType,
      categorias: Map<String, double>.from(_categorias),
    );

    // Guardar en la lista de presupuestos
    final presupuestos = await PresupuestosHelpers.loadPresupuestos();
    final index = presupuestos.indexWhere((p) => p.id == widget.presupuesto.id);
    if (index != -1) {
      presupuestos[index] = updatedBudget;
      await PresupuestosHelpers.savePresupuestos(presupuestos);
    }

    // Actualizar selección activa si es necesario
    final prefs = await SharedPreferences.getInstance();
    final activeBudgetId = prefs.getString('presupuesto_activo_id');
    if (activeBudgetId == widget.presupuesto.id) {
      await prefs.setString('presupuesto_activo_id', updatedBudget.id);
      await prefs.setInt(
        'presupuesto_unificado_seleccionado',
        widget.presupuestoIndex,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
      Navigator.pop(context, updatedBudget);
    }
  }

  Future<void> _editCategoryAmount(
    String categoria,
    double currentAmount,
  ) async {
    final controller = TextEditingController(
      text: formatCurrency(currentAmount),
    );
    final focus = FocusNode();

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editar $categoria',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Monto para $categoria:'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  focusNode: focus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(null),
                      child: Text(AppLocalizations.of(sheetContext)!.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop(parseMonto(controller.text) ?? 0);
                      },
                      child: Text(AppLocalizations.of(sheetContext)!.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    focus.dispose();

    if (result != null) {
      if (!mounted) return;
      setState(() {
        _categorias[categoria] = result;
      });
    }
  }

  Color _getProgressColor(double ratio) {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.75) return Colors.orange;
    if (ratio >= 0.5) return Colors.amber.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final totalAssigned = _categorias.values.fold<double>(0, (a, b) => a + b);
    final totalSpent = _gastado.values.fold<double>(0, (a, b) => a + b);
    final totalRemaining = (totalAssigned - totalSpent).clamp(
      0,
      double.infinity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Presupuesto'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveBudget),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica del presupuesto
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Básica',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.budgetNameOptional,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Presupuesto',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Diario', 'Semanal', 'Mensual', 'Anual']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value ?? _selectedType;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumen financiero
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen Financiero',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Asignado',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    formatCurrency(totalAssigned),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Gastado',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    formatCurrency(totalSpent),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Restante',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    formatCurrency(totalRemaining),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categorías
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorías del Presupuesto',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          if (_categorias.isEmpty)
                            Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.noCategoriesAvailable,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _categorias.entries.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final entry = _categorias.entries.elementAt(
                                  index,
                                );
                                final categoria = entry.key;
                                final asignado = entry.value;
                                final gastado = _gastado[categoria] ?? 0;
                                final restante = (asignado - gastado).clamp(
                                  0,
                                  double.infinity,
                                );
                                final ratio = asignado > 0
                                    ? (gastado / asignado).toDouble()
                                    : 0.0;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    categoria,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Asignado: ${formatCurrency(asignado)} | Gastado: ${formatCurrency(gastado)} | Restante: ${formatCurrency(restante)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: ratio.clamp(0, 1),
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _getProgressColor(ratio),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(ratio * 100).toStringAsFixed(1)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: _getProgressColor(ratio),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editCategoryAmount(
                                      categoria,
                                      asignado,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Espacio para el botón flotante
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveBudget,
        icon: const Icon(Icons.save),
        label: Text(AppLocalizations.of(context)!.save),
      ),
    );
  }
}
