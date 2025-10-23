// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Luz en el Gasto';

  @override
  String get registerExpense => 'Registrar despesa';

  @override
  String get expenseHistory => 'Histórico de despesas';

  @override
  String get budgets => 'Orçamentos';

  @override
  String get settings => 'Configurações';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get amount => 'Valor';

  @override
  String get category => 'Categoria';

  @override
  String get noteOptional => 'Observação (opcional)';

  @override
  String get noBudgetSelectedWarning =>
      'Nenhum orçamento selecionado. A despesa não será deduzida de nenhum orçamento.';

  @override
  String get selectCategory => 'Selecionar categoria';

  @override
  String get categories => 'Categorias';

  @override
  String get addCategory => 'Adicionar categoria';

  @override
  String get saveExpense => 'Salvar despesa';

  @override
  String get insufficientFunds =>
      'Saldo insuficiente na categoria selecionada.';

  @override
  String get editExpense => 'Editar despesa';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get ok => 'OK';

  @override
  String get savedBudgets => 'Saved budgets';

  @override
  String get noSavedBudgets => 'No saved budgets';

  @override
  String get createNewBudget => 'Create new budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get saveBudget => 'Save budget';

  @override
  String get updateBudget => 'Update budget';

  @override
  String get budgetNameOptional => 'Budget name (optional)';

  @override
  String totalLabel(Object total) {
    return 'Total: $total';
  }

  @override
  String categoriesOf(Object name) {
    return 'Categories of $name';
  }

  @override
  String get close => 'Close';

  @override
  String get unspecifiedName => '(Unnamed)';

  @override
  String typeLabel(Object type) {
    return 'Type: $type';
  }

  @override
  String get noCategoriesAvailable => 'No categories available.';

  @override
  String availableBalanceInCategory(Object balance) {
    return 'Available balance in this category: $balance';
  }

  @override
  String get registerByVoice => 'Register by voice';

  @override
  String get pleaseEnterAmountAndCategory =>
      'Please enter amount and category.';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodBiweekly => 'Biweekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get create => 'Criar';

  @override
  String get editName => 'Editar nome';

  @override
  String get nameOptional => 'Nome (opcional)';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get noCategoriesWithBalance => 'Não há categorias com saldo';

  @override
  String get chartTypeLabel => 'Chart type:';

  @override
  String get chartBars => 'Bars';

  @override
  String get chartPie => 'Pie';

  @override
  String totalPeriodLabel(Object period, Object total) {
    return 'Total ($period): $total';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noExpensesRegistered => 'No expenses registered.';

  @override
  String budgetSavedForCategory(Object category) {
    return 'Budget for \"$category\" saved.';
  }

  @override
  String get budgetByCategory => 'Budget by Category';

  @override
  String get defineBudgetByCategory => 'Define the budget per category:';

  @override
  String get customCategories => 'Custom categories';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get currencyFormatLabel => 'Formato de moeda';

  @override
  String get currencySymbol => 'Símbolo';

  @override
  String get thousandSeparator => 'Separador de milhares';

  @override
  String get decimalSeparator => 'Separador decimal';

  @override
  String get saveCurrencyFormat => 'Salvar formato de moeda';

  @override
  String get weekStartAndDateFormat => 'Início da semana e formato de data';

  @override
  String get monday => 'Segunda-feira';

  @override
  String get sunday => 'Domingo';

  @override
  String get dateFormatLabel => 'Formato de data';

  @override
  String get invalidDateFormat => 'Formato de data inválido';

  @override
  String get saved => 'Salvo';

  @override
  String get saveWeekStartAndFormat => 'Salvar início de semana e formato';

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
  String get addCategoryHint => 'Nome da nova categoria';

  @override
  String get exampleLabel => 'Exemplo';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportedFile => 'Arquivo gerado';

  @override
  String get invalidAmount => 'Valor inválido. Introduza um número positivo.';

  @override
  String get invalidAmountFormat =>
      'Formato inválido. Use \'.\' para milhares e \',\' para decimais.';

  @override
  String get selectCategoryDialogTitle => 'Selecionar uma categoria';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSelect => 'Selecionar';

  @override
  String get noNote => 'Sem nota';

  @override
  String budgetSaved(Object period) {
    return 'Orçamento $period salvo';
  }
}
