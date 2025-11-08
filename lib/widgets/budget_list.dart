import 'package:flutter/material.dart';
import '../models/presupuesto_unificado.dart';
import '../shared/utils/format_utils.dart';
import '../l10n/app_localizations.dart';

typedef IntCallback = void Function(int index);

class BudgetList extends StatelessWidget {
  final List<PresupuestoUnificado> presupuestos;
  final String? activeBudgetId;
  final IntCallback onTap;
  final IntCallback onSelectToggle;
  final IntCallback onRename;
  final IntCallback onDelete;

  const BudgetList({
    super.key,
    required this.presupuestos,
    required this.activeBudgetId,
    required this.onTap,
    required this.onSelectToggle,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (presupuestos.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noSavedBudgets));
    }
    return ListView.builder(
      itemCount: presupuestos.length,
      itemBuilder: (ctx, i) {
        final p = presupuestos[i];
        // Calcular total usando centavos para evitar discrepancias de redondeo
        final totalCents = p.categorias.values.fold<int>(
          0,
          (a, b) => a + ((b * 100).round()),
        );
        final total = totalCents / 100.0;
        return Card(
          child: ListTile(
            selected: activeBudgetId == p.id,
            selectedTileColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            title: Text(
              p.nombre.isEmpty
                  ? AppLocalizations.of(context)!.unspecifiedName
                  : p.nombre,
            ),
            subtitle: Text(
              '${p.tipo} • ${AppLocalizations.of(context)!.totalLabel(formatCurrency(total))}',
            ),
            onTap: () => onTap(i),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    activeBudgetId == p.id
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: activeBudgetId == p.id ? Colors.green : null,
                  ),
                  onPressed: () => onSelectToggle(i),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onRename(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(i),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
