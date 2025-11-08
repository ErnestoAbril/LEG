import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'presupuesto_categoria_repository.dart';
import 'features/budgets/domain/entities/budget_period.dart';
import 'legacy_gasto_repository.dart';
import 'shared/utils/format_utils.dart';

class GestionPresupuestosCategoriaScreen extends StatefulWidget {
  final PeriodoPresupuesto periodo;
  const GestionPresupuestosCategoriaScreen({super.key, required this.periodo});

  @override
  State<GestionPresupuestosCategoriaScreen> createState() =>
      _GestionPresupuestosCategoriaScreenState();
}

class _GestionPresupuestosCategoriaScreenState
    extends State<GestionPresupuestosCategoriaScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, double> _valores = {};
  bool _cargando = true;
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _valores = await PresupuestoCategoriaRepository.obtenerTodosPorPeriodo(
      widget.periodo,
    );
    for (var cat in GastoRepository.categoriasIniciales) {
      final val = _valores[cat] ?? 0;
      final ctrl = TextEditingController(
        text: val > 0 ? formatNumberForInput(val) : '',
      );
      final focus = FocusNode();
      focus.addListener(() {
        if (focus.hasFocus) return;
        final raw = ctrl.text;
        final v = parseMonto(raw);
        if (v != null) {
          final f = formatNumberForInput(v);
          if (f != raw) {
            ctrl.text = f;
            ctrl.selection = TextSelection.collapsed(offset: f.length);
          }
        }
      });
      _controllers[cat] = ctrl;
      _focusNodes[cat] = focus;
    }
    setState(() => _cargando = false);
  }

  Future<void> _guardar(String cat) async {
    final valor = parseMonto(_controllers[cat]?.text ?? '') ?? 0;
    await PresupuestoCategoriaRepository.guardarPresupuesto(
      widget.periodo,
      cat,
      valor,
    );
    if (!mounted) return;
    setState(() => _valores[cat] = valor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.budgetSavedForCategory(cat),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.budgetByCategory} (${widget.periodo.localized(context)})',
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  Text(
                    AppLocalizations.of(context)!.defineBudgetByCategory,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ...GastoRepository.categoriasIniciales.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _controllers[cat],
                              focusNode: _focusNodes[cat],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                // intentionally no label text to avoid the word shown in the UI
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _guardar(cat),
                            child: Text(AppLocalizations.of(context)!.save),
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
