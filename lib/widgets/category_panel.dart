import 'package:flutter/material.dart';
import '../models/presupuesto_unificado.dart';
import '../shared/utils/format_utils.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../legacy_gasto_repository.dart';

typedef OnCategoryUpdated = Future<void> Function(String cat, double value);

class CategoryPanel extends StatefulWidget {
  final PresupuestoUnificado presupuesto;
  final OnCategoryUpdated onUpdate;

  const CategoryPanel({
    super.key,
    required this.presupuesto,
    required this.onUpdate,
  });

  @override
  State<CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<CategoryPanel> {
  Map<String, double> _gastado = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarGastado();
  }

  Future<void> _cargarGastado() async {
    setState(() => _cargando = true);
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
    if (mounted) setState(() => _cargando = false);
  }

  void _recalcAfterEdit() {
    // Recalculate remaining values after a category amount change
    _cargarGastado();
  }

  Color _colorForRatio(double ratio, ThemeData theme) {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.75) return Colors.orange;
    if (ratio >= 0.5) return Colors.amber.shade700;
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.presupuesto;

    return DraggableScrollableSheet(
      initialChildSize: 1.0, // Inicia ocupando toda la pantalla
      minChildSize: 0.25,
      maxChildSize: 1.0, // Puede ocupar toda la pantalla
      builder: (context, controller) {
        final surface = Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalCents = p.categorias.values.fold<int>(
              0,
              (a, b) => a + ((b * 100).round()),
            );
            final modalTotal = totalCents / 100.0;
            final gastadoTotal = _gastado.entries.fold<double>(
              0,
              (a, b) => a + b.value,
            );
            final restanteTotal = (modalTotal - gastadoTotal).clamp(
              0,
              double.infinity,
            );

            return Container(
              decoration: BoxDecoration(
                color: surface,
                // Sin borderRadius para pantalla completa
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.categoriesOf(
                              p.nombre.isEmpty
                                  ? AppLocalizations.of(
                                      context,
                                    )!.unspecifiedName
                                  : p.nombre,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: onSurface,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            'Asignado: ${formatCurrency(modalTotal)}\nConsumido: ${formatCurrency(gastadoTotal)}\nRestante: ${formatCurrency(restanteTotal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.close,
                          icon: const Icon(Icons.close),
                          splashRadius: 20,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: ListView(
                        controller: controller,
                        children: [
                          if (_cargando)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          // show all categories ordered by remaining ascending (more critical first)
                          ...(() {
                            final list = p.categorias.entries.map((e) {
                              final cat = e.key;
                              final val = e.value;
                              final spent = _gastado[cat] ?? 0;
                              final remaining = (val - spent).clamp(
                                0,
                                double.infinity,
                              );
                              final ratio = val > 0
                                  ? (spent / val).clamp(0, 1)
                                  : 0.0;
                              return {
                                'cat': cat,
                                'assigned': val,
                                'spent': spent,
                                'remaining': remaining,
                                'ratio': ratio,
                              };
                            }).toList();
                            // Ordenar por saldo restante (mayor a menor)
                            list.sort(
                              (a, b) => (b['remaining'] as double).compareTo(
                                a['remaining'] as double,
                              ),
                            );
                            return list.map((m) {
                              final theme = Theme.of(context);
                              final cat = m['cat'] as String;
                              final val = m['assigned'] as double;
                              final spent = m['spent'] as double;
                              final remaining = m['remaining'] as double;
                              final ratio = m['ratio'] as double;
                              final color = _colorForRatio(ratio, theme);
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    cat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Asignado: ${formatCurrency(val)}  |  Consumido: ${formatCurrency(spent)}  |  Restante: ${formatCurrency(remaining)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: ratio,
                                          minHeight: 6,
                                          backgroundColor: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          valueColor: AlwaysStoppedAnimation(
                                            color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(ratio * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    tooltip: AppLocalizations.of(
                                      context,
                                    )!.editBudget,
                                    onPressed: () => _editCategoryAmount(
                                      cat,
                                      val,
                                      setModalState,
                                    ),
                                  ),
                                ),
                              );
                            }).toList();
                          })(),
                          if (p.categorias.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.noCategoriesAvailable,
                                style: TextStyle(
                                  color: onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editCategoryAmount(
    String cat,
    double currentValue,
    void Function(void Function()) setModalState,
  ) async {
    final TextEditingController valueCtrl = TextEditingController(
      text: formatNumberForInput(currentValue),
    );
    final FocusNode valueFocus = FocusNode();
    valueFocus.addListener(() {
      if (valueFocus.hasFocus) return; // format only on blur
      final parsed = parseMonto(valueCtrl.text);
      if (parsed != null) {
        final f = formatNumberForInput(parsed);
        if (f != valueCtrl.text) {
          valueCtrl.text = f;
          valueCtrl.selection = TextSelection.collapsed(offset: f.length);
        }
      }
    });

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppLocalizations.of(ctx)!.editBudget} — $cat',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  focusNode: valueFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.amount,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppLocalizations.of(ctx)!.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(AppLocalizations.of(ctx)!.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // capture ok result and then dispose
    if (ok == true) {
      final raw = valueCtrl.text;
      final parsed = parseMonto(raw) ?? double.nan;
      if (!parsed.isFinite || parsed < 0 || parsed > 1e12) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.invalidAmount)),
        );
        valueCtrl.dispose();
        valueFocus.dispose();
        return;
      }
      final rounded = ((parsed * 100).round()) / 100.0;
      await widget.onUpdate(cat, rounded);
      _recalcAfterEdit();
      setModalState(() {});
      if (!mounted) return;
      setState(() {});
    }
    valueCtrl.dispose();
    valueFocus.dispose();
  }
}
