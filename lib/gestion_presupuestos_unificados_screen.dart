// ignore_for_file: use_build_context_synchronously
// shorter orchestrator using extracted widgets
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/presupuesto_unificado.dart';
import 'helpers/presupuestos_helpers.dart';
import 'widgets/budget_list.dart';
import 'l10n/app_localizations.dart';
import 'legacy_gasto_repository.dart';
import 'budget_edit_screen.dart';
import 'budget_view_screen.dart';

class GestionPresupuestosUnificadosScreen extends StatefulWidget {
  const GestionPresupuestosUnificadosScreen({super.key});

  @override
  State<GestionPresupuestosUnificadosScreen> createState() =>
      _GestionPresupuestosUnificadosScreenState();
}

class _GestionPresupuestosUnificadosScreenState
    extends State<GestionPresupuestosUnificadosScreen> {
  static const _activeBudgetKey = 'presupuesto_activo_id';

  final List<PresupuestoUnificado> _presupuestos = [];
  String? _activeBudgetId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loaded = await PresupuestosHelpers.loadPresupuestos();
    if (!mounted) return;
    setState(() => _presupuestos.addAll(loaded));
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_activeBudgetKey);
    if (id != null && !_presupuestos.any((p) => p.id == id)) {
      await prefs.remove(_activeBudgetKey);
      if (!mounted) return;
      setState(() => _activeBudgetId = null);
    } else {
      if (!mounted) return;
      setState(() => _activeBudgetId = id);
    }
  }

  Future<void> _save() async =>
      PresupuestosHelpers.savePresupuestos(_presupuestos);

  Future<void> _createBudget() async {
    final nameCtrl = TextEditingController();
    String tipo = 'Mensual';
    final res = await showModalBottomSheet<bool>(
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
                  AppLocalizations.of(ctx)!.createNewBudget,
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.budgetNameOptional,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: tipo,
                  items: ['Diario', 'Semanal', 'Mensual', 'Anual']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => tipo = v ?? tipo,
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
                      child: Text(AppLocalizations.of(ctx)!.createNewBudget),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (res == true) {
      final Map<String, double> cats = {
        for (var c in GastoRepository.categoriasIniciales) c: 0.0,
      };
      final nuevo = PresupuestoUnificado(
        nombre: nameCtrl.text.trim(),
        tipo: tipo,
        categorias: cats,
      );
      setState(() {
        _presupuestos.add(nuevo);
        _activeBudgetId = nuevo.id;
      });
      await _save();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeBudgetKey, nuevo.id);
      await prefs.setInt(
        'presupuesto_unificado_seleccionado',
        _presupuestos.indexOf(nuevo),
      );
    }
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.budgets)),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBudget,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.savedBudgets,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BudgetList(
                presupuestos: _presupuestos,
                activeBudgetId: _activeBudgetId,
                onTap: (i) async {
                  // Abrir pantalla de visualización del presupuesto
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => BudgetViewScreen(
                        presupuesto: _presupuestos[i],
                        presupuestoIndex: i,
                      ),
                    ),
                  );
                },
                onSelectToggle: (i) async {
                  final p = _presupuestos[i];
                  final prefs = await SharedPreferences.getInstance();
                  if (_activeBudgetId == p.id) {
                    await prefs.remove(_activeBudgetKey);
                    await prefs.remove('presupuesto_unificado_seleccionado');
                    setState(() => _activeBudgetId = null);
                  } else {
                    await prefs.setString(_activeBudgetKey, p.id);
                    await prefs.setInt('presupuesto_unificado_seleccionado', i);
                    setState(() => _activeBudgetId = p.id);
                  }
                },
                onRename: (i) async {
                  // Abrir pantalla completa de edición
                  final updatedBudget =
                      await Navigator.push<PresupuestoUnificado>(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => BudgetEditScreen(
                            presupuesto: _presupuestos[i],
                            presupuestoIndex: i,
                          ),
                        ),
                      );

                  if (updatedBudget != null) {
                    setState(() {
                      _presupuestos[i] = updatedBudget;
                    });
                    // Recargar datos frescos
                    final reloaded =
                        await PresupuestosHelpers.loadPresupuestos();
                    final refreshed = reloaded.firstWhere(
                      (b) => b.id == updatedBudget.id,
                      orElse: () => updatedBudget,
                    );
                    setState(() => _presupuestos[i] = refreshed);
                  }
                },
                onDelete: (i) async {
                  final p = _presupuestos[i];
                  final wasActive = _activeBudgetId == p.id;
                  setState(() => _presupuestos.removeAt(i));
                  if (wasActive) setState(() => _activeBudgetId = null);
                  final prefs = await SharedPreferences.getInstance();
                  if (_activeBudgetId == null) {
                    await prefs.remove(_activeBudgetKey);
                    await prefs.remove('presupuesto_unificado_seleccionado');
                  }
                  await _save();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
