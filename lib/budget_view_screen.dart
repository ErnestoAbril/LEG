import 'package:flutter/material.dart';
import 'models/presupuesto_unificado.dart';
import 'format_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class BudgetViewScreen extends StatefulWidget {
  final PresupuestoUnificado presupuesto;
  final int presupuestoIndex;

  const BudgetViewScreen({
    super.key,
    required this.presupuesto,
    required this.presupuestoIndex,
  });

  @override
  State<BudgetViewScreen> createState() => _BudgetViewScreenState();
}

class _BudgetViewScreenState extends State<BudgetViewScreen> {
  late PresupuestoUnificado _currentPresupuesto;
  Map<String, double> _gastado = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentPresupuesto = widget.presupuesto;
    _loadGastado();
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
      } else {
        _gastado = {};
      }
    } catch (_) {
      _gastado = {};
    }
    if (mounted) setState(() => _loading = false);
  }

  double get _totalAsignado => _currentPresupuesto.categorias.values.fold(
    0.0,
    (sum, amount) => sum + amount,
  );
  double get _totalGastado =>
      _gastado.values.fold(0.0, (sum, amount) => sum + amount);
  double get _totalRestante => _totalAsignado - _totalGastado;

  double _getProgressRatio() {
    if (_totalAsignado <= 0) return 0.0;
    final ratio = _totalGastado / _totalAsignado;
    return ratio.clamp(0.0, 1.0);
  }

  Color _getProgressColor() {
    final ratio = _getProgressRatio();
    if (ratio <= 0.7) return Colors.green;
    if (ratio <= 0.9) return Colors.orange;
    return Colors.red;
  }

  double _getGastadoForCategoria(String categoria, double asignado) =>
      _gastado[categoria] ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Presupuesto'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Presupuesto',
            onPressed: () {
              // Aquí podrías navegar a la pantalla de edición si quisieras
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Para editar, usa el botón de editar en la lista de presupuestos',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información Básica (Solo lectura)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Básica',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre del presupuesto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentPresupuesto.nombre.isEmpty
                                      ? 'Sin nombre'
                                      : _currentPresupuesto.nombre,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipo de Presupuesto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _getTypeIcon(_currentPresupuesto.tipo),
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentPresupuesto.tipo,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumen Financiero
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen Financiero',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Asignado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatCurrency(_totalAsignado),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Gastado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatCurrency(_totalGastado),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Restante',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatCurrency(_totalRestante),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _totalRestante >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _getProgressRatio(),
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_getProgressRatio() * 100).toStringAsFixed(1)}% del presupuesto utilizado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categorías del Presupuesto
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorías del Presupuesto',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ..._currentPresupuesto.categorias.entries.map((
                            entry,
                          ) {
                            final categoria = entry.key;
                            final asignado = entry.value;
                            final gastado = _getGastadoForCategoria(
                              categoria,
                              asignado,
                            );
                            final restante = asignado - gastado;
                            final percentage = asignado > 0
                                ? (gastado / asignado * 100)
                                : 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        categoria,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.grey.shade500,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Asignado: ${formatCurrency(asignado)} | '
                                    'Gastado: ${formatCurrency(gastado)} | '
                                    'Restante: ${formatCurrency(restante)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: asignado > 0
                                          ? (gastado / asignado).clamp(0.0, 1.0)
                                          : 0.0,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage <= 70
                                            ? Colors.green
                                            : percentage <= 90
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Diario':
        return Icons.today;
      case 'Semanal':
        return Icons.date_range;
      case 'Mensual':
        return Icons.calendar_month;
      case 'Anual':
        return Icons.event;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
