// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luz en el Gasto';

  @override
  String get registerExpense => 'Register Expense';

  @override
  String get expenseHistory => 'Expense History';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noBudgetSelectedWarning =>
      'No budget selected. The expense won\'t be deducted from any budget.';

  @override
  String get selectCategory => 'Select category';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get insufficientFunds => 'Insufficient funds in selected category.';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get saveChanges => 'Save Changes';

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
  String get create => 'Create';

  @override
  String get editName => 'Edit name';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get noCategoriesWithBalance => 'No categories with balance';

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
  String get languageLabel => 'Language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get currencyFormatLabel => 'Currency format';

  @override
  String get currencySymbol => 'Symbol';

  @override
  String get thousandSeparator => 'Thousand separator';

  @override
  String get decimalSeparator => 'Decimal separator';

  @override
  String get saveCurrencyFormat => 'Save currency format';

  @override
  String get weekStartAndDateFormat => 'Week start and date format';

  @override
  String get monday => 'Monday';

  @override
  String get sunday => 'Sunday';

  @override
  String get dateFormatLabel => 'Date format';

  @override
  String get invalidDateFormat => 'Invalid date format';

  @override
  String get saved => 'Saved';

  @override
  String get saveWeekStartAndFormat => 'Save week start and format';

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
  String get addCategoryHint => 'New category name';

  @override
  String get exampleLabel => 'Example';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportedFile => 'Generated file';

  @override
  String get invalidAmount => 'Invalid amount. Please enter a positive number.';

  @override
  String get invalidAmountFormat =>
      'Invalid format. Use \'.\' for thousands and \',\' for decimals.';

  @override
  String get selectCategoryDialogTitle => 'Select a category';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSelect => 'Select';

  @override
  String get noNote => 'No note';

  @override
  String budgetSaved(Object period) {
    return 'Budget $period saved';
  }
}
