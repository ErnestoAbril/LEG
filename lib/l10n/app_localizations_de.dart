// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Luz en el Gasto';

  @override
  String get registerExpense => 'Ausgabe erfassen';

  @override
  String get expenseHistory => 'Ausgabenverlauf';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Einstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get amount => 'Betrag';

  @override
  String get category => 'Kategorie';

  @override
  String get noteOptional => 'Notiz (optional)';

  @override
  String get noBudgetSelectedWarning =>
      'Kein Budget ausgewählt. Die Ausgabe wird nicht von einem Budget abgezogen.';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get insufficientFunds =>
      'Nicht genügend Mittel in der ausgewählten Kategorie.';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get ok => 'OK';

  @override
  String get savedBudgets => 'Saved budgets';

  @override
  String get noSavedBudgets => 'No saved budgets';

  @override
  String get createNewBudget => 'Neues Budget erstellen';

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
  String get create => 'Erstellen';

  @override
  String get editName => 'Namen bearbeiten';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get noCategoriesWithBalance => 'Keine Kategorien mit Guthaben';

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
  String get languageLabel => 'Sprache';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get currencyFormatLabel => 'Währungsformat';

  @override
  String get currencySymbol => 'Symbol';

  @override
  String get thousandSeparator => 'Tausender-Trennzeichen';

  @override
  String get decimalSeparator => 'Dezimaltrennzeichen';

  @override
  String get saveCurrencyFormat => 'Währungsformat speichern';

  @override
  String get weekStartAndDateFormat => 'Wochenstart und Datumsformat';

  @override
  String get monday => 'Montag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get dateFormatLabel => 'Datumsformat';

  @override
  String get invalidDateFormat => 'Ungültiges Datumsformat';

  @override
  String get saved => 'Gespeichert';

  @override
  String get saveWeekStartAndFormat => 'Wochenstart und Format speichern';

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
  String get addCategoryHint => 'Name der neuen Kategorie';

  @override
  String get exampleLabel => 'Beispiel';

  @override
  String get exportPdf => 'PDF exportieren';

  @override
  String get exportCsv => 'CSV exportieren';

  @override
  String get exportedFile => 'Generierte Datei';

  @override
  String get invalidAmount =>
      'Ungültiger Betrag. Bitte geben Sie eine positive Zahl ein.';

  @override
  String get invalidAmountFormat =>
      'Ungültiges Format. Verwenden Sie \'.\' für Tausender und \',\' für Dezimalstellen.';

  @override
  String get selectCategoryDialogTitle => 'Kategorie auswählen';

  @override
  String get dialogCancel => 'Abbrechen';

  @override
  String get dialogSelect => 'Auswählen';

  @override
  String get noNote => 'Keine Notiz';

  @override
  String budgetSaved(Object period) {
    return 'Budget $period gespeichert';
  }
}
