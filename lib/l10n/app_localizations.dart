import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Luz en el Gasto'**
  String get appTitle;

  /// No description provided for @registerExpense.
  ///
  /// In en, this message translates to:
  /// **'Register Expense'**
  String get registerExpense;

  /// No description provided for @expenseHistory.
  ///
  /// In en, this message translates to:
  /// **'Expense History'**
  String get expenseHistory;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noBudgetSelectedWarning.
  ///
  /// In en, this message translates to:
  /// **'No budget selected. The expense won\'t be deducted from any budget.'**
  String get noBudgetSelectedWarning;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds in selected category.'**
  String get insufficientFunds;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @savedBudgets.
  ///
  /// In en, this message translates to:
  /// **'Saved budgets'**
  String get savedBudgets;

  /// No description provided for @noSavedBudgets.
  ///
  /// In en, this message translates to:
  /// **'No saved budgets'**
  String get noSavedBudgets;

  /// No description provided for @createNewBudget.
  ///
  /// In en, this message translates to:
  /// **'Create new budget'**
  String get createNewBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get saveBudget;

  /// No description provided for @updateBudget.
  ///
  /// In en, this message translates to:
  /// **'Update budget'**
  String get updateBudget;

  /// No description provided for @budgetNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Budget name (optional)'**
  String get budgetNameOptional;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String totalLabel(Object total);

  /// No description provided for @categoriesOf.
  ///
  /// In en, this message translates to:
  /// **'Categories of {name}'**
  String categoriesOf(Object name);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unspecifiedName.
  ///
  /// In en, this message translates to:
  /// **'(Unnamed)'**
  String get unspecifiedName;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String typeLabel(Object type);

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available.'**
  String get noCategoriesAvailable;

  /// No description provided for @availableBalanceInCategory.
  ///
  /// In en, this message translates to:
  /// **'Available balance in this category: {balance}'**
  String availableBalanceInCategory(Object balance);

  /// No description provided for @registerByVoice.
  ///
  /// In en, this message translates to:
  /// **'Register by voice'**
  String get registerByVoice;

  /// No description provided for @pleaseEnterAmountAndCategory.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount and category.'**
  String get pleaseEnterAmountAndCategory;

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// No description provided for @periodBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get periodBiweekly;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @periodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @editCategories.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get editCategories;

  /// No description provided for @noCategoriesWithBalance.
  ///
  /// In en, this message translates to:
  /// **'No categories with balance'**
  String get noCategoriesWithBalance;

  /// No description provided for @chartTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Chart type:'**
  String get chartTypeLabel;

  /// No description provided for @chartBars.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get chartBars;

  /// No description provided for @chartPie.
  ///
  /// In en, this message translates to:
  /// **'Pie'**
  String get chartPie;

  /// No description provided for @totalPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Total ({period}): {total}'**
  String totalPeriodLabel(Object period, Object total);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @noExpensesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No expenses registered.'**
  String get noExpensesRegistered;

  /// No description provided for @budgetSavedForCategory.
  ///
  /// In en, this message translates to:
  /// **'Budget for \"{category}\" saved.'**
  String budgetSavedForCategory(Object category);

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'Budget by Category'**
  String get budgetByCategory;

  /// No description provided for @defineBudgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'Define the budget per category:'**
  String get defineBudgetByCategory;

  /// No description provided for @customCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom categories'**
  String get customCategories;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @currencyFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency format'**
  String get currencyFormatLabel;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get currencySymbol;

  /// No description provided for @thousandSeparator.
  ///
  /// In en, this message translates to:
  /// **'Thousand separator'**
  String get thousandSeparator;

  /// No description provided for @decimalSeparator.
  ///
  /// In en, this message translates to:
  /// **'Decimal separator'**
  String get decimalSeparator;

  /// No description provided for @saveCurrencyFormat.
  ///
  /// In en, this message translates to:
  /// **'Save currency format'**
  String get saveCurrencyFormat;

  /// No description provided for @weekStartAndDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Week start and date format'**
  String get weekStartAndDateFormat;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @dateFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormatLabel;

  /// No description provided for @invalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format'**
  String get invalidDateFormat;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @saveWeekStartAndFormat.
  ///
  /// In en, this message translates to:
  /// **'Save week start and format'**
  String get saveWeekStartAndFormat;

  /// No description provided for @languageName_es.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageName_es;

  /// No description provided for @languageName_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName_en;

  /// No description provided for @languageName_pt.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languageName_pt;

  /// No description provided for @languageName_fr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageName_fr;

  /// No description provided for @languageName_de.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageName_de;

  /// No description provided for @addCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get addCategoryHint;

  /// No description provided for @exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get exampleLabel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportedFile.
  ///
  /// In en, this message translates to:
  /// **'Generated file'**
  String get exportedFile;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount. Please enter a positive number.'**
  String get invalidAmount;

  /// No description provided for @invalidAmountFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format. Use \'.\' for thousands and \',\' for decimals.'**
  String get invalidAmountFormat;

  /// No description provided for @selectCategoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryDialogTitle;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get dialogSelect;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get noNote;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget {period} saved'**
  String budgetSaved(Object period);

  /// No description provided for @categoryReachedThreshold.
  ///
  /// In en, this message translates to:
  /// **'Category \"{category}\" reached {percent}% of the budget.'**
  String categoryReachedThreshold(Object category, Object percent);

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donationUrlOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open donation link.'**
  String get donationUrlOpenError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
