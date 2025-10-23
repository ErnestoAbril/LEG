// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Luz en el Gasto';

  @override
  String get registerExpense => 'Enregistrer une dépense';

  @override
  String get expenseHistory => 'Historique des dépenses';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Paramètres';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get amount => 'Montant';

  @override
  String get category => 'Catégorie';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String get noBudgetSelectedWarning =>
      'Aucun budget sélectionné. La dépense ne sera déduite d\'aucun budget.';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get categories => 'Catégories';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get saveExpense => 'Enregistrer la dépense';

  @override
  String get insufficientFunds =>
      'Fonds insuffisants dans la catégorie sélectionnée.';

  @override
  String get editExpense => 'Modifier la dépense';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get ok => 'OK';

  @override
  String get savedBudgets => 'Budgets enregistrés';

  @override
  String get noSavedBudgets => 'Aucun budget enregistré';

  @override
  String get createNewBudget => 'Créer un nouveau budget';

  @override
  String get editBudget => 'Modifier le budget';

  @override
  String get saveBudget => 'Enregistrer le budget';

  @override
  String get updateBudget => 'Mettre à jour le budget';

  @override
  String get budgetNameOptional => 'Nom du budget (facultatif)';

  @override
  String totalLabel(Object total) {
    return 'Total: $total';
  }

  @override
  String categoriesOf(Object name) {
    return 'Catégories de $name';
  }

  @override
  String get close => 'Fermer';

  @override
  String get unspecifiedName => '(Sans nom)';

  @override
  String typeLabel(Object type) {
    return 'Type: $type';
  }

  @override
  String get noCategoriesAvailable => 'Aucune catégorie disponible.';

  @override
  String availableBalanceInCategory(Object balance) {
    return 'Solde disponible dans cette catégorie : $balance';
  }

  @override
  String get registerByVoice => 'Enregistrer par la voix';

  @override
  String get pleaseEnterAmountAndCategory =>
      'Veuillez entrer le montant et la catégorie.';

  @override
  String get periodDaily => 'Quotidien';

  @override
  String get periodWeekly => 'Hebdomadaire';

  @override
  String get periodBiweekly => 'Bihebdomadaire';

  @override
  String get periodMonthly => 'Mensuel';

  @override
  String get periodYearly => 'Annuel';

  @override
  String get create => 'Créer';

  @override
  String get editName => 'Modifier le nom';

  @override
  String get nameOptional => 'Nom (optionnel)';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get noCategoriesWithBalance => 'Aucune catégorie avec solde';

  @override
  String get chartTypeLabel => 'Type de graphique:';

  @override
  String get chartBars => 'Barres';

  @override
  String get chartPie => 'Camembert';

  @override
  String totalPeriodLabel(Object period, Object total) {
    return 'Total ($period): $total';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get noExpensesRegistered => 'Aucune dépense enregistrée.';

  @override
  String budgetSavedForCategory(Object category) {
    return 'Budget de \"$category\" enregistré.';
  }

  @override
  String get budgetByCategory => 'Budget par catégorie';

  @override
  String get defineBudgetByCategory => 'Définissez le budget par catégorie:';

  @override
  String get customCategories => 'Catégories personnalisées';

  @override
  String get languageLabel => 'Langue';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get currencyFormatLabel => 'Format de la monnaie';

  @override
  String get currencySymbol => 'Symbole';

  @override
  String get thousandSeparator => 'Séparateur des milliers';

  @override
  String get decimalSeparator => 'Séparateur décimal';

  @override
  String get saveCurrencyFormat => 'Enregistrer le format de la monnaie';

  @override
  String get weekStartAndDateFormat => 'Début de la semaine et format de date';

  @override
  String get monday => 'Lundi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get dateFormatLabel => 'Format de date';

  @override
  String get invalidDateFormat => 'Format de date invalide';

  @override
  String get saved => 'Enregistré';

  @override
  String get saveWeekStartAndFormat =>
      'Enregistrer le début de semaine et le format';

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
  String get addCategoryHint => 'Nom de la nouvelle catégorie';

  @override
  String get exampleLabel => 'Exemple';

  @override
  String get exportPdf => 'Exporter PDF';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get exportedFile => 'Fichier généré';

  @override
  String get invalidAmount => 'Montant inválide. Entrez un numéro positif.';

  @override
  String get invalidAmountFormat =>
      'Format invalide. Utilisez \'.\' para milhares e \',\' para décimales.';

  @override
  String get selectCategoryDialogTitle => 'Sélectionner une catégorie';

  @override
  String get dialogCancel => 'Annuler';

  @override
  String get dialogSelect => 'Sélectionner';

  @override
  String get noNote => 'Pas de note';

  @override
  String budgetSaved(Object period) {
    return 'Budget $period enregistré';
  }
}
