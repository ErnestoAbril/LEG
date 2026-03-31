// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Luz en el Gasto';

  @override
  String get registerExpense => 'Registrar Gasto';

  @override
  String get expenseHistory => 'Historial de Gastos';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get settings => 'Configuración';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoría';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get noBudgetSelectedWarning =>
      'No hay un presupuesto seleccionado. El gasto no se descontará de ningún presupuesto.';

  @override
  String get selectCategory => 'Selecciona categoría';

  @override
  String get categories => 'Categorías';

  @override
  String get addCategory => 'Agregar categoría';

  @override
  String get saveExpense => 'Guardar Gasto';

  @override
  String get insufficientFunds =>
      'No hay saldo suficiente en la categoría seleccionada.';

  @override
  String get editExpense => 'Editar Gasto';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get ok => 'OK';

  @override
  String get savedBudgets => 'Presupuestos guardados';

  @override
  String get noSavedBudgets => 'No hay presupuestos guardados';

  @override
  String get createNewBudget => 'Crear nuevo presupuesto';

  @override
  String get editBudget => 'Editar presupuesto';

  @override
  String get saveBudget => 'Guardar presupuesto';

  @override
  String get updateBudget => 'Actualizar presupuesto';

  @override
  String get budgetNameOptional => 'Nombre del presupuesto (opcional)';

  @override
  String totalLabel(Object total) {
    return 'Total: $total';
  }

  @override
  String categoriesOf(Object name) {
    return 'Categorías de $name';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get unspecifiedName => '(Sin nombre)';

  @override
  String typeLabel(Object type) {
    return 'Tipo: $type';
  }

  @override
  String get noCategoriesAvailable => 'No hay categorías disponibles.';

  @override
  String availableBalanceInCategory(Object balance) {
    return 'Saldo disponible en esta categoría: $balance';
  }

  @override
  String get registerByVoice => 'Registrar por voz';

  @override
  String get pleaseEnterAmountAndCategory =>
      'Por favor ingresa monto y categoría.';

  @override
  String get periodDaily => 'Diario';

  @override
  String get periodWeekly => 'Semanal';

  @override
  String get periodBiweekly => 'Quincenal';

  @override
  String get periodMonthly => 'Mensual';

  @override
  String get periodYearly => 'Anual';

  @override
  String get create => 'Crear';

  @override
  String get editName => 'Editar nombre';

  @override
  String get nameOptional => 'Nombre (opcional)';

  @override
  String get editCategories => 'Editar categorías';

  @override
  String get noCategoriesWithBalance => 'No hay categorías con saldo';

  @override
  String get chartTypeLabel => 'Tipo de gráfico:';

  @override
  String get chartBars => 'Barras';

  @override
  String get chartPie => 'Pastel';

  @override
  String totalPeriodLabel(Object period, Object total) {
    return 'Total ($period): $total';
  }

  @override
  String get dateLabel => 'Fecha';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get noExpensesRegistered => 'No hay gastos registrados.';

  @override
  String budgetSavedForCategory(Object category) {
    return 'Presupuesto de \"$category\" guardado.';
  }

  @override
  String get budgetByCategory => 'Presupuesto por Categoría';

  @override
  String get defineBudgetByCategory => 'Define el presupuesto por categoría:';

  @override
  String get customCategories => 'Categorías personalizadas';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get currencyFormatLabel => 'Formato de moneda';

  @override
  String get currencySymbol => 'Símbolo';

  @override
  String get thousandSeparator => 'Separador miles';

  @override
  String get decimalSeparator => 'Separador decimales';

  @override
  String get saveCurrencyFormat => 'Guardar formato de moneda';

  @override
  String get weekStartAndDateFormat => 'Inicio de semana y formato de fecha';

  @override
  String get monday => 'Lunes';

  @override
  String get sunday => 'Domingo';

  @override
  String get dateFormatLabel => 'Formato de fecha';

  @override
  String get invalidDateFormat => 'Formato de fecha inválido';

  @override
  String get saved => 'Guardado';

  @override
  String get saveWeekStartAndFormat => 'Guardar inicio de semana y formato';

  @override
  String get languageName_es => 'Español';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_pt => 'Português';

  @override
  String get languageName_fr => 'Français';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get addCategoryHint => 'Nombre de la nueva categoría';

  @override
  String get exampleLabel => 'Ejemplo';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportedFile => 'Archivo generado';

  @override
  String get invalidAmount =>
      'Monto inválido. Ingresa un número positivo válido.';

  @override
  String get invalidAmountFormat =>
      'Formato inválido. Use miles con \'.\' y decimales con \',\'.';

  @override
  String get selectCategoryDialogTitle => 'Selecciona una categoría';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSelect => 'Seleccionar';

  @override
  String get noNote => 'Sin nota';

  @override
  String budgetSaved(Object period) {
    return 'Presupuesto $period guardado';
  }

  @override
  String categoryReachedThreshold(Object category, Object percent) {
    return 'La categoría \"$category\" alcanzó $percent% del presupuesto.';
  }

  @override
  String get donate => 'Donar';

  @override
  String get donationUrlOpenError => 'No se pudo abrir el enlace de donación.';
}
