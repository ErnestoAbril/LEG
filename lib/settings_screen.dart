import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_repository.dart';
import 'app_settings.dart';
import 'l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _newCat = TextEditingController();
  List<String> _cats = [];
  String _lang = 'es';
  ThemeMode _theme = ThemeMode.system;
  final TextEditingController _currencySymbol = TextEditingController();
  final TextEditingController _decimalSepCtrl = TextEditingController();
  final TextEditingController _thousandSepCtrl = TextEditingController();
  WeekStart _weekStart = WeekStart.monday;
  final TextEditingController _dateFormatCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _cats = await CategoryRepository.getCustomCategories();
    final lang = await CategoryRepository.getLanguage();
    // load current theme from global notifier
    _theme = appThemeNotifier.value;
    final cur = currencyNotifier.value;
    _currencySymbol.text = cur.symbol;
    _decimalSepCtrl.text = cur.decimalSeparator;
    _thousandSepCtrl.text = cur.thousandSeparator;
    // load date/week settings from global notifiers
    _weekStart = weekStartNotifier.value;
    _dateFormatCtrl.text = dateFormatNotifier.value;
    setState(() {
      _lang = lang ?? 'es';
    });
  }

  Future<void> _add() async {
    final t = _newCat.text.trim();
    if (t.isEmpty) return;
    await CategoryRepository.addCategory(t);
    _newCat.clear();
    await _load();
  }

  Future<void> _remove(String cat) async {
    await CategoryRepository.removeCategory(cat);
    await _load();
  }

  Future<void> _setLang(String lang) async {
    await CategoryRepository.setLanguage(lang);
    // Update UI state and global locale notifier so MaterialApp picks the new locale.
    setState(() => _lang = lang);
    // update global locale
    try {
      // avoid importing app_settings at top to prevent cycles; import here
      // (import added below)
      appLocaleNotifier.value = lang.isNotEmpty ? Locale(lang) : null;
    } catch (_) {}
  }

  Future<void> _setTheme(ThemeMode m) async {
    await saveTheme(m);
    setState(() => _theme = m);
  }

  Future<void> _saveCurrency() async {
    final s = _currencySymbol.text.trim().isEmpty
        ? '\$'
        : _currencySymbol.text.trim();
    final dec = _decimalSepCtrl.text.trim().isEmpty
        ? '.'
        : _decimalSepCtrl.text.trim();
    final thou = _thousandSepCtrl.text.trim().isEmpty
        ? ','
        : _thousandSepCtrl.text.trim();
    // Validaciones básicas: separadores de un solo carácter y distintos.
    if (dec.length != 1 || thou.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidDateFormat),
        ),
      );
      return;
    }
    if (dec == thou) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Separadores deben ser distintos')),
      );
      return;
    }
    await saveCurrencySettings(
      CurrencySettings(
        symbol: s,
        decimalSeparator: dec,
        thousandSeparator: thou,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: SafeArea(
        child: SingleChildScrollView(
          // add bottom padding so the keyboard doesn't cover content / cause overflow
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              16.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.customCategories,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCat,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.addCategoryHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _add,
                      child: Text(AppLocalizations.of(context)!.addCategory),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mostrar lista de categorías sin fijar altura — shrinkWrap evita conflictos dentro de SingleChildScrollView
                ListView.builder(
                  itemCount: _cats.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (c, i) {
                    final cat = _cats[i];
                    return ListTile(
                      title: Text(cat),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _remove(cat),
                      ),
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.languageLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _lang,
                  items: [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(
                        AppLocalizations.of(context)!.languageName_es,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        AppLocalizations.of(context)!.languageName_en,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pt',
                      child: Text(
                        AppLocalizations.of(context)!.languageName_pt,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text(
                        AppLocalizations.of(context)!.languageName_fr,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'de',
                      child: Text(
                        AppLocalizations.of(context)!.languageName_de,
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) _setLang(v);
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.themeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<ThemeMode>(
                  value: _theme,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(AppLocalizations.of(context)!.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(AppLocalizations.of(context)!.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(AppLocalizations.of(context)!.themeDark),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) _setTheme(v);
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.currencyFormatLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _currencySymbol,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.currencySymbol,
                    hintText: '\$',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _thousandSepCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.thousandSeparator,
                          hintText: ',',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _decimalSepCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.decimalSeparator,
                          hintText: '.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveCurrency,
                  child: Text(AppLocalizations.of(context)!.saveCurrencyFormat),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.weekStartAndDateFormat,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<WeekStart>(
                  value: _weekStart,
                  items: [
                    DropdownMenuItem(
                      value: WeekStart.monday,
                      child: Text(AppLocalizations.of(context)!.monday),
                    ),
                    DropdownMenuItem(
                      value: WeekStart.sunday,
                      child: Text(AppLocalizations.of(context)!.sunday),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _weekStart = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateFormatCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dateFormatLabel,
                    hintText: 'dd/MM/yyyy',
                  ),
                ),
                const SizedBox(height: 8),
                // Preview del formato de fecha y validación
                (() {
                  final f = _dateFormatCtrl.text.trim().isEmpty
                      ? dateFormatNotifier.value
                      : _dateFormatCtrl.text.trim();
                  String preview;
                  try {
                    preview = DateFormat(f).format(DateTime.now());
                  } catch (_) {
                    preview = 'Formato inválido';
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.exampleLabel}: $preview',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final fmt = _dateFormatCtrl.text.trim().isEmpty
                              ? 'dd/MM/yyyy'
                              : _dateFormatCtrl.text.trim();
                          // validar formato
                          try {
                            DateFormat(fmt).format(DateTime.now());
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.invalidDateFormat,
                                ),
                              ),
                            );
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          final savedLabel = AppLocalizations.of(
                            context,
                          )!.saved;
                          await saveDateSettings(_weekStart, fmt);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text(savedLabel)),
                          );
                          setState(() {});
                        },
                        child: Text(
                          AppLocalizations.of(context)!.saveWeekStartAndFormat,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Export feature was removed per request
                    ],
                  );
                })(),
              ],
            ), // Column
          ), // Padding
        ), // SingleChildScrollView
      ), // SafeArea
    ); // Scaffold
  }
}
