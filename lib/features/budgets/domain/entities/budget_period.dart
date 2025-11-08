import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Budget period enumeration for different budget timeframes
enum PeriodoPresupuesto { 
  diario, 
  semanal, 
  quincenal, 
  mensual, 
  anual 
}

/// Extension for PeriodoPresupuesto with localization and utility methods
extension PeriodoPresupuestoExt on PeriodoPresupuesto {
  /// Returns an internal non-localized name (enum name) for storage or logic.
  String get nameLabel {
    switch (this) {
      case PeriodoPresupuesto.diario:
        return 'Diario';
      case PeriodoPresupuesto.semanal:
        return 'Semanal';
      case PeriodoPresupuesto.quincenal:
        return 'Quincenal';
      case PeriodoPresupuesto.mensual:
        return 'Mensual';
      case PeriodoPresupuesto.anual:
        return 'Anual';
    }
  }

  /// Returns a localized label using the provided [BuildContext].
  String localized(BuildContext context) {
    switch (this) {
      case PeriodoPresupuesto.diario:
        return AppLocalizations.of(context)!.periodDaily;
      case PeriodoPresupuesto.semanal:
        return AppLocalizations.of(context)!.periodWeekly;
      case PeriodoPresupuesto.quincenal:
        return AppLocalizations.of(context)!.periodBiweekly;
      case PeriodoPresupuesto.mensual:
        return AppLocalizations.of(context)!.periodMonthly;
      case PeriodoPresupuesto.anual:
        return AppLocalizations.of(context)!.periodYearly;
    }
  }

  /// Get the number of days for this period
  int get days {
    switch (this) {
      case PeriodoPresupuesto.diario:
        return 1;
      case PeriodoPresupuesto.semanal:
        return 7;
      case PeriodoPresupuesto.quincenal:
        return 15;
      case PeriodoPresupuesto.mensual:
        return 30;
      case PeriodoPresupuesto.anual:
        return 365;
    }
  }

  /// Convert from string name to enum
  static PeriodoPresupuesto? fromName(String name) {
    switch (name.toLowerCase()) {
      case 'diario':
        return PeriodoPresupuesto.diario;
      case 'semanal':
        return PeriodoPresupuesto.semanal;
      case 'quincenal':
        return PeriodoPresupuesto.quincenal;
      case 'mensual':
        return PeriodoPresupuesto.mensual;
      case 'anual':
        return PeriodoPresupuesto.anual;
      default:
        return null;
    }
  }
}