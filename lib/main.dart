import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presupuesto_repository.dart';
import 'widgets/simple_radio_group.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'gestion_presupuestos_unificados_screen.dart';
import 'presupuesto_categoria_repository.dart';
import 'category_repository.dart';
import 'settings_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'app_settings.dart';
import 'format_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
part 'main.g.dart';

// Formatting helpers moved to format_utils.dart

// Reutilizar un reproductor para evitar crear instancias repetidas
final AudioPlayer _sharedAudioPlayer = AudioPlayer();

Future<void> playAlertaSonora() async {
  try {
    await _sharedAudioPlayer.play(AssetSource('alerta.mp3'));
  } catch (_) {
    // Si falla la reproducción, no bloquear la app.
  }
}

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String monto;
  @HiveField(1)
  String categoria;
  @HiveField(2)
  String nota;
  @HiveField(3)
  DateTime fecha;
  @HiveField(4)
  int? presupuestoId; // Nuevo: id del presupuesto unificado
  @HiveField(5)
  int? montoCents; // nuevo campo canonico (entero en centavos)

  Gasto({
    required this.monto,
    required this.categoria,
    required this.nota,
    required this.fecha,
    this.presupuestoId,
    this.montoCents,
  });
}

class GastoRepository {
  static ValueListenable<Box<Gasto>> boxListenable() {
    return _box.listenable();
  }

  static const List<String> categoriasIniciales = [
    'Supermercado',
    'Transporte',
    'Comida',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Servicios',
    'Ropa',
    'Mascotas',
    'Hogar',
    'Regalos',
    'Otros',
  ];
  static List<String> obtenerCategoriasFrecuentes({int top = 8}) {
    final gastos = _box.values.toList();
    final Map<String, int> conteo = {};
    for (var g in gastos) {
      final cat = g.categoria.trim();
      if (cat.isNotEmpty) conteo[cat] = (conteo[cat] ?? 0) + 1;
    }
    final ordenadas = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final frecuentes = ordenadas.take(top).map((e) => e.key).toList();
    // Combina iniciales y frecuentes, sin duplicados
    final todas = [...categoriasIniciales, ...frecuentes];
    return {for (var c in todas) c.trim(): null}.keys.toList();
  }

  static late Box<Gasto> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Gasto>('gastos');
    // Migración ligera: rellenar montoCents para gastos antiguos si falta
    final saves = <Future>[];
    for (final g in _box.values) {
      if (g.montoCents == null) {
        final parsed = parseMonto(g.monto) ?? 0;
        g.montoCents = (parsed * 100).round();
        saves.add(g.save());
      }
    }
    if (saves.isNotEmpty) await Future.wait(saves);
  }

  static Future<void> agregarGasto(Gasto gasto) async {
    await _box.add(gasto);
  }

  static List<Gasto> obtenerGastosPorPresupuesto(int? presupuestoId) {
    if (presupuestoId == null) {
      return [];
    }
    return _box.values.where((g) => g.presupuestoId == presupuestoId).toList();
  }

  static List<Gasto> obtenerGastos() {
    final gastos = _box.values.toList().reversed.toList();
    return gastos;
  }
}

enum PeriodoPresupuesto { diario, semanal, quincenal, mensual, anual }

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
}

// PresupuestoRepository moved to `lib/presupuesto_repository.dart` to reduce main.dart size.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  await GastoRepository.init();
  // load persisted settings (theme + currency)
  await loadSavedTheme();
  await loadCurrencySettings();
  await loadDateSettings();
  await loadSavedLocale();
  runApp(const LuzEnElGastoApp());
}

class LuzEnElGastoApp extends StatelessWidget {
  const LuzEnElGastoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: appLocaleNotifier,
          builder: (context, locale, __) {
            // Escuchar también cambios de formato de moneda para forzar rebuild de textos formateados.
            return ValueListenableBuilder<CurrencySettings>(
              valueListenable: currencyNotifier,
              builder: (context, currencySettings, ___) {
                return MaterialApp(
                  title: 'Luz en el Gasto',
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                    ),
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                      brightness: Brightness.dark,
                    ),
                    useMaterial3: true,
                  ),
                  themeMode: mode,
                  home: const MainMenuScreen(),
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        );
      },
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(AppLocalizations.of(context)!.registerExpense),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroGastoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: Text(AppLocalizations.of(context)!.expenseHistory),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistorialGastosScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: Text(AppLocalizations.of(context)!.budgets),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GestionPresupuestosUnificadosScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!.settings),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RegistroGastoScreen extends StatefulWidget {
  const RegistroGastoScreen({super.key});

  @override
  State<RegistroGastoScreen> createState() => _RegistroGastoScreenState();
}

class _RegistroGastoScreenState extends State<RegistroGastoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  int? _presupuestoSeleccionado;
  Map<String, double> _saldosCategorias = {};
  Map<String, double> _montosOriginalesCategorias = {};
  List<String> _categoriasDisponibles = [];
  String? _nombrePresupuestoSeleccionado;
  // GlobalKey para el Autocomplete; el estado interno no está expuesto públicamente,
  // por eso mantenemos un GlobalKey sin tipado concreto aquí.
  final GlobalKey _autoKey = GlobalKey();
  bool _formattingMonto = false;
  late FocusNode _montoFocus;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _cargarPresupuestoSeleccionado();
    // Usar focus node: formatear SOLO cuando el campo pierde foco (comportamiento clásico).
    _montoFocus = FocusNode();
    _montoFocus.addListener(() {
      if (_montoFocus.hasFocus) {
        return; // only act on blur
      }
      if (_formattingMonto) {
        return;
      }
      _formattingMonto = true;
      final raw = _montoController.text;
      final v = parseMonto(raw);
      if (v != null) {
        final f = formatNumberForInput(v);
        if (f != raw) {
          _montoController.text = f;
          _montoController.selection = TextSelection.collapsed(
            offset: f.length,
          );
        }
      }
      _formattingMonto = false;
    });
  }

  Future<void> _cargarPresupuestoSeleccionado() async {
    final prefs = await SharedPreferences.getInstance();
    // First try the integer index (legacy)
    int? selectedIndex = prefs.getInt('presupuesto_unificado_seleccionado');
    // If not present, try the new string id and map it to an index
    if (selectedIndex == null) {
      final activeId = prefs.getString('presupuesto_activo_id');
      if (activeId != null) {
        final presupuestosPrefs = prefs.getString('presupuestos_unificados');
        if (presupuestosPrefs != null) {
          try {
            final List decoded = jsonDecode(presupuestosPrefs);
            final idx = decoded.indexWhere((p) {
              try {
                return (p['id'] as String?) == activeId;
              } catch (_) {
                return false;
              }
            });
            if (idx >= 0) {
              selectedIndex = idx;
              // store integer for backward compatibility
              await prefs.setInt('presupuesto_unificado_seleccionado', idx);
            } else {
              // stale id: remove it
              await prefs.remove('presupuesto_activo_id');
            }
          } catch (_) {
            await prefs.remove('presupuesto_activo_id');
          }
        } else {
          await prefs.remove('presupuesto_activo_id');
        }
      }
    }

    _presupuestoSeleccionado = selectedIndex;
    if (_presupuestoSeleccionado != null) {
      // Obtener presupuesto y gastos para calcular saldos
      final presupuestosPrefs = prefs.getString('presupuestos_unificados');
      if (presupuestosPrefs != null) {
        final List decoded = jsonDecode(presupuestosPrefs);
        if (_presupuestoSeleccionado! < decoded.length) {
          final presupuesto = decoded[_presupuestoSeleccionado!];
          final Map<String, double> categorias = Map<String, double>.from(
            (presupuesto['categorias'] as Map).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ),
          );
          _montosOriginalesCategorias = Map<String, double>.from(categorias);
          // Obtener gastos de este presupuesto
          final gastos = GastoRepository.obtenerGastosPorPresupuesto(
            _presupuestoSeleccionado,
          );
          final Map<String, double> gastadoPorCat = {};
          for (var g in gastos) {
            final monto = g.montoCents != null
                ? g.montoCents! / 100.0
                : (parseMonto(g.monto) ?? 0);
            gastadoPorCat[g.categoria] =
                (gastadoPorCat[g.categoria] ?? 0) + monto;
          }
          _saldosCategorias = {};
          categorias.forEach((cat, monto) {
            final gastado = gastadoPorCat[cat] ?? 0;
            _saldosCategorias[cat] = monto - gastado;
          });
          // Solo categorías con saldo positivo
          _categoriasDisponibles = _saldosCategorias.entries
              .where((e) => e.value > 0)
              .map((e) => e.key)
              .toList();
          // Guardar el nombre del presupuesto seleccionado
          _nombrePresupuestoSeleccionado =
              (presupuesto['nombre'] as String?)?.isNotEmpty == true
              ? presupuesto['nombre'] as String
              : '(Sin nombre)';
        } else {
          _nombrePresupuestoSeleccionado = null;
        }
      } else {
        _nombrePresupuestoSeleccionado = null;
      }
    } else {
      // Sin presupuesto: combinar categorías iniciales, frecuentes y personalizadas
      final frecuentes = GastoRepository.obtenerCategoriasFrecuentes();
      final custom = await CategoryRepository.getCustomCategories();
      final todas = <String>{
        ...GastoRepository.categoriasIniciales,
        ...frecuentes,
        ...custom,
      }.toList();
      _categoriasDisponibles = todas;
      _nombrePresupuestoSeleccionado = null;
    }
    setState(() {});
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              _parseSpeech(_lastWords);
            });
          },
        );
      }
    } else {
        setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _parseSpeech(String text) {
    // Ejemplo: "Gasté 20000 en mercado" o "Compré pan 1500"
    final montoRegExp = RegExp(r'(\d{1,}[\.,]?\d{0,})');
    final categoriaRegExp = RegExp(
      r'en ([a-zA-ZáéíóúÁÉÍÓÚñÑ ]+)',
      caseSensitive: false,
    );
    String monto = '';
    String categoria = '';

    // Intentar parsear con la lógica centralizada primero (maneja separadores y símbolos).
    final parsedByHelper = parseMonto(text);
    if (parsedByHelper != null) {
      monto = formatNumberForInput(parsedByHelper);
    } else {
      // Fallback: extraer dígitos sueltos como antes
      final montoMatch = montoRegExp.firstMatch(
        text.replaceAll('.', '').replaceAll(',', ''),
      );
      if (montoMatch != null) {
        monto = montoMatch.group(0) ?? '';
      }
    }

    final categoriaMatch = categoriaRegExp.firstMatch(text);
    if (categoriaMatch != null) {
      categoria = categoriaMatch.group(1)?.trim() ?? '';
    } else {
      // Si no encuentra "en ...", intenta tomar la última palabra como categoría
      final palabras = text.split(' ');
      if (palabras.length > 1) {
        categoria = palabras.last;
      }
    }

    if (monto.isNotEmpty) _montoController.text = monto;
    if (categoria.isNotEmpty) _categoriaController.text = categoria;
    _notaController.text = text;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _categoriaController.dispose();
    _notaController.dispose();
    _montoFocus.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController newCatCtrl = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addCategory),
          content: TextField(
            controller: newCatCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.category,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final text = newCatCtrl.text.trim();
                if (text.isNotEmpty) Navigator.of(context).pop(text);
              },
              child: Text(AppLocalizations.of(context)!.addCategory),
            ),
          ],
        );
      },
    );
    if (result != null && result.trim().isNotEmpty) {
      final nueva = result.trim();
      await CategoryRepository.addCategory(nueva);
      // actualizar la lista local de categorias disponibles cuando no hay presupuesto
      if (_presupuestoSeleccionado == null) {
        final custom = await CategoryRepository.getCustomCategories();
        final frecuentes = GastoRepository.obtenerCategoriasFrecuentes();
        final todas = <String>{
          ...GastoRepository.categoriasIniciales,
          ...frecuentes,
          ...custom,
        }.toList();
        setState(() {
          _categoriasDisponibles = todas;
          _categoriaController.text = nueva;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaSeleccionada = _categoriaController.text;
    final saldoCategoria =
        (_presupuestoSeleccionado != null &&
            categoriaSeleccionada.isNotEmpty &&
            _saldosCategorias.containsKey(categoriaSeleccionada))
        ? _saldosCategorias[categoriaSeleccionada] ?? 0
        : null;
    // Eliminadas variables locales no usadas para limpiar warnings de lint
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerExpense),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_presupuestoSeleccionado != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_categoriasDisponibles.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final displayName =
                                      (_nombrePresupuestoSeleccionado != null &&
                                          _nombrePresupuestoSeleccionado!
                                              .isNotEmpty)
                                      ? _nombrePresupuestoSeleccionado!
                                      : '#$_presupuestoSeleccionado';
                                  return Text(
                                    '${AppLocalizations.of(context)!.savedBudgets}: $displayName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Debug: show available categories (helps diagnose why Autocomplete may be empty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                      child: Text(
                        '${AppLocalizations.of(context)!.categories} (${_categoriasDisponibles.length}): ${_categoriasDisponibles.join(', ')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.noBudgetSelectedWarning,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _montoController,
                focusNode: _montoFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_presupuestoSeleccionado != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.category),
                  title: Text(
                    _categoriaController.text.isNotEmpty
                        ? _categoriaController.text
                        : AppLocalizations.of(context)!.selectCategory,
                  ),
                  subtitle: _categoriasDisponibles.isEmpty
                      ? Text(
                          AppLocalizations.of(context)!.noBudgetSelectedWarning,
                        )
                      : null,
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final seleccion = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.selectCategory,
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: _categoriasDisponibles.isEmpty
                                ? Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.noCategoriesAvailable,
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _categoriasDisponibles.length,
                                    itemBuilder: (context, index) {
                                      final opt = _categoriasDisponibles[index];
                                      final saldo =
                                          _saldosCategorias[opt] ?? 0.0;
                                      final original =
                                          _montosOriginalesCategorias[opt];
                                      return ListTile(
                                        title: Text(opt),
                                        subtitle: original != null
                                            ? Text(
                                                '${formatCurrency(saldo)} / ${formatCurrency(original)}',
                                              )
                                            : null,
                                        trailing: Text(formatCurrency(saldo)),
                                        onTap: () =>
                                            Navigator.of(context).pop(opt),
                                      );
                                    },
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(null),
                              child: Text(AppLocalizations.of(context)!.ok),
                            ),
                          ],
                        );
                      },
                    );
                    if (seleccion != null) {
                      _categoriaController.text = seleccion;
                      setState(() {});
                    }
                  },
                )
              else
                Autocomplete<String>(
                  key: _autoKey,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    final cats = _categoriasDisponibles;
                    if (textEditingValue.text.isEmpty) {
                      return cats;
                    }
                    return cats.where(
                      (c) => c.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // keep the local controller in sync with the backing controller only when different
                    if (controller.text != _categoriaController.text) {
                      controller.text = _categoriaController.text;
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                    final bool readOnlyField = _presupuestoSeleccionado != null;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      readOnly: readOnlyField,
                      decoration: InputDecoration(
                        labelText: readOnlyField
                            ? AppLocalizations.of(context)!.selectCategory
                            : AppLocalizations.of(context)!.category,
                        prefixIcon: const Icon(Icons.category),
                        // cuando NO hay presupuesto seleccionado mostramos un botón para agregar categoría
                        suffixIcon: readOnlyField
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.add),
                                tooltip: AppLocalizations.of(
                                  context,
                                )!.addCategory,
                                onPressed: () => _showAddCategoryDialog(),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                        onChanged: (val) {
                          if (readOnlyField) {
                            return; // ignore manual typing when a budget is selected
                          }
                          _categoriaController.text = val;
                          setState(() {});
                        },
                      onTap: () {
                        // when tapping the field (no presupuesto), force focus and open options so the user
                        // can see the full list without typing
                        focusNode.requestFocus();
                        try {
                          // AutocompleteState.showOptions() call
                          (_autoKey.currentState as dynamic)?.showOptions();
                        } catch (_) {}
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final opts = options.toList();
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 400,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: opts.length,
                            itemBuilder: (context, index) {
                              final String opt = opts[index];
                              final saldo = _saldosCategorias[opt] ?? 0.0;
                              return ListTile(
                                title: Text(opt),
                                trailing: Text(formatCurrency(saldo)),
                                onTap: () => onSelected(opt),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    _categoriaController.text = selection;
                    setState(() {});
                  },
                ),
              if (_presupuestoSeleccionado != null &&
                  categoriaSeleccionada.isNotEmpty &&
                  saldoCategoria != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    AppLocalizations.of(context)!.availableBalanceInCategory(
                      formatCurrency(saldoCategoria),
                    ),
                    style: TextStyle(
                      color: saldoCategoria <= 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _notaController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.noteOptional,
                        prefixIcon: const Icon(Icons.note),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    tooltip: AppLocalizations.of(context)!.registerByVoice,
                    onPressed: _listen,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.saveExpense),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _guardarGasto,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MÉTODO FUERA DEL BUILD:
  void _guardarGasto() async {
    if (_montoController.text.isNotEmpty &&
        _categoriaController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final presupuestoId = prefs.getInt('presupuesto_unificado_seleccionado');
      final montoGasto = parseMonto(_montoController.text) ?? 0;
      if (presupuestoId != null) {
        await _cargarPresupuestoSeleccionado();
        final saldoCat = _saldosCategorias[_categoriaController.text] ?? 0;
        if (montoGasto > saldoCat) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.insufficientFunds),
            ),
          );
          return;
        }
      }
      final cents = (montoGasto * 100).round();
      final formattedForStorage = formatNumberForInput(montoGasto);
      final gasto = Gasto(
        monto: formattedForStorage,
        categoria: _categoriaController.text,
        nota: _notaController.text,
        fecha: DateTime.now(),
        presupuestoId: presupuestoId,
        montoCents: cents,
      );
      await GastoRepository.agregarGasto(gasto);
      // Ya no descontamos el presupuesto al guardar: el saldo se calcula como Asignado - Consumido.
      if (presupuestoId != null) {
        await _cargarPresupuestoSeleccionado();
      }
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterAmountAndCategory,
          ),
        ),
      );
    }
  }
}

class EditarGastoScreen extends StatefulWidget {
  final Gasto gasto;
  const EditarGastoScreen({super.key, required this.gasto});

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  late TextEditingController _montoController;
  late TextEditingController _categoriaController;
  late TextEditingController _notaController;
  late FocusNode _montoEditFocus;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(text: widget.gasto.monto);
    _categoriaController = TextEditingController(text: widget.gasto.categoria);
    _notaController = TextEditingController(text: widget.gasto.nota);
    _montoEditFocus = FocusNode();
    _montoEditFocus.addListener(() {
      if (_montoEditFocus.hasFocus) {
        return;
      }
      final raw = _montoController.text;
      final v = parseMonto(raw);
      if (v != null) {
        final f = formatNumberForInput(v);
        if (f != raw) {
          _montoController.text = f;
          _montoController.selection = TextSelection.collapsed(
            offset: f.length,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _categoriaController.dispose();
    _notaController.dispose();
    _montoEditFocus.dispose();
    super.dispose();
  }

  void _guardarEdicion() async {
    // Normalizar y recalcular montoCents
    final parsed = parseMonto(_montoController.text) ?? 0;
    widget.gasto.montoCents = (parsed * 100).round();
    widget.gasto.monto = formatNumberForInput(parsed);
    widget.gasto.categoria = _categoriaController.text;
    widget.gasto.nota = _notaController.text;
    await widget.gasto.save();
    if (!mounted) {
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editExpense)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _montoController,
              focusNode: _montoEditFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoriaController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.category,
                prefixIcon: const Icon(Icons.category),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notaController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.noteOptional,
                prefixIcon: const Icon(Icons.note),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)!.saveChanges),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: _guardarEdicion,
            ),
          ],
        ),
      ),
    );
  }
}

class HistorialGastosScreen extends StatefulWidget {
  const HistorialGastosScreen({super.key});

  @override
  State<HistorialGastosScreen> createState() => _HistorialGastosScreenState();
}

enum PeriodoHistorial {
  diario,
  semanal,
  quincenal,
  mensual,
  trimestral,
  semestral,
  anual,
}

extension PeriodoHistorialExt on PeriodoHistorial {
  String get label {
    switch (this) {
      case PeriodoHistorial.diario:
        return 'Diario';
      case PeriodoHistorial.semanal:
        return 'Semanal';
      case PeriodoHistorial.quincenal:
        return 'Quincenal';
      case PeriodoHistorial.mensual:
        return 'Mensual';
      case PeriodoHistorial.trimestral:
        return 'Trimestral';
      case PeriodoHistorial.semestral:
        return 'Semestral';
      case PeriodoHistorial.anual:
        return 'Anual';
    }
  }

  /// Returns a localized label using the provided [BuildContext].
  ///
  /// Note: not all historical periods have dedicated localization keys in the
  /// ARB files; for those cases this falls back to the internal `label`.
  String localized(BuildContext context) {
    switch (this) {
      case PeriodoHistorial.diario:
        return AppLocalizations.of(context)!.periodDaily;
      case PeriodoHistorial.semanal:
        return AppLocalizations.of(context)!.periodWeekly;
      case PeriodoHistorial.quincenal:
        return AppLocalizations.of(context)!.periodBiweekly;
      case PeriodoHistorial.mensual:
        return AppLocalizations.of(context)!.periodMonthly;
      case PeriodoHistorial.trimestral:
        // No dedicated key; fall back to the internal label (will be Spanish by default).
        return label;
      case PeriodoHistorial.semestral:
        // No dedicated key; fall back to the internal label.
        return label;
      case PeriodoHistorial.anual:
        return AppLocalizations.of(context)!.periodYearly;
    }
  }
}

enum TipoGrafico { barras, pastel }

class PreferenciasUsuario {
  static const String _keyTipoGrafico = 'tipo_grafico';
  static const String _keyMostrarLeyendaPastel = 'mostrar_leyenda_pastel';

  static Future<TipoGrafico> obtenerTipoGrafico() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_keyTipoGrafico) ?? 0;
    return TipoGrafico.values[idx];
  }

  static Future<void> guardarTipoGrafico(TipoGrafico tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTipoGrafico, tipo.index);
  }

  static Future<bool> obtenerMostrarLeyenda() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMostrarLeyendaPastel) ?? true;
  }

  static Future<void> guardarMostrarLeyenda(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMostrarLeyendaPastel, v);
  }
}

class _HistorialGastosScreenState extends State<HistorialGastosScreen> {
  bool _mostrarLeyenda = true;
  @override
  void initState() {
    super.initState();
    // Carga la preferencia guardada del tipo de gráfico al iniciar la pantalla
    PreferenciasUsuario.obtenerTipoGrafico().then((tipo) {
      setState(() => _tipoGrafico = tipo);
    });
    PreferenciasUsuario.obtenerMostrarLeyenda().then((v) {
      setState(() => _mostrarLeyenda = v);
    });
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _seleccionarCategoria(List<Gasto> gastos) async {
    final categorias = gastos.map((g) => g.categoria).toSet().toList();
    String? seleccion = _categoriaSeleccionada;
    final seleccionada = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectCategory),
              content: SizedBox(
                width: double.maxFinite,
                child: SimpleRadioGroup<String>(
                  values: categorias,
                  selected: seleccion,
                  onChanged: (v) => setStateDialog(() => seleccion = v),
                  itemBuilder: (cat, selected) => ListTile(
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected ? Colors.deepPurple : null,
                    ),
                    title: Text(cat),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(seleccion),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      },
    );
    if (seleccionada != null) {
      setState(() {
        _categoriaSeleccionada = seleccionada;
      });
    }
  }

  DateTime? _fechaSeleccionada;
  String? _categoriaSeleccionada;
  final double _presupuesto = 0;
  final PeriodoPresupuesto _periodo = PeriodoPresupuesto.mensual;
  PeriodoHistorial _periodoHistorial = PeriodoHistorial.mensual;
  TipoGrafico _tipoGrafico = TipoGrafico.barras;

  // _crearBarGroups fue reemplazado por una versión inline con precomputo en el Builder.

  Widget _buildBarLegend(List<Gasto> gastos) {
    final Map<String, double> data = {};
    for (var g in gastos) {
      final monto = g.montoCents != null
          ? g.montoCents! / 100.0
          : (parseMonto(g.monto) ?? 0);
      data[g.categoria] = (data[g.categoria] ?? 0) + monto;
    }
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    final total = data.values.fold(0.0, (a, b) => a + b);
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    final items = data.entries.map((e) {
      final color = colors[i++ % colors.length];
      final percent = total > 0 ? (e.value / total * 100) : 0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${e.key}: ${percent.toStringAsFixed(1)}% (${formatCurrency(e.value)})',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(spacing: 16, runSpacing: 8, children: items),
    );
  }

  List<PieChartSectionData> _crearPieSections(List<Gasto> gastos) {
    final Map<String, double> data = {};
    for (var g in gastos) {
      final monto = g.montoCents != null
          ? g.montoCents! / 100.0
          : (parseMonto(g.monto) ?? 0);
      data[g.categoria] = (data[g.categoria] ?? 0) + monto;
    }
    final total = data.values.fold(0.0, (a, b) => a + b);
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return data.entries.map((e) {
      final percent = total > 0 ? (e.value / total * 100) : 0;
      final section = PieChartSectionData(
        color: colors[i % colors.length],
        value: e.value,
        title: '${e.key}\n${percent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      i++;
      return section;
    }).toList();
  }

  Widget _buildPieLegend(List<Gasto> gastos) {
    final Map<String, double> data = {};
    for (var g in gastos) {
      final monto = g.montoCents != null
          ? g.montoCents! / 100.0
          : (parseMonto(g.monto) ?? 0);
      data[g.categoria] = (data[g.categoria] ?? 0) + monto;
    }
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    final total = data.values.fold(0.0, (a, b) => a + b);
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    final items = data.entries.map((e) {
      final color = colors[i++ % colors.length];
      final percent = total > 0 ? (e.value / total * 100) : 0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${e.key}: ${percent.toStringAsFixed(1)}% (${formatCurrency(e.value)})',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(spacing: 16, runSpacing: 8, children: items),
    );
  }

  DateTime _inicioPeriodo(PeriodoHistorial periodo) {
    final ahora = DateTime.now();
    switch (periodo) {
      case PeriodoHistorial.diario:
        return DateTime(ahora.year, ahora.month, ahora.day);
      case PeriodoHistorial.semanal:
        // Respect user's week start preference (Monday or Sunday)
        if (weekStartNotifier.value == WeekStart.monday) {
          final inicio = ahora.subtract(Duration(days: ahora.weekday - 1));
          return DateTime(inicio.year, inicio.month, inicio.day);
        } else {
          // Week starts on Sunday: DateTime.weekday == 7 for Sunday
          final inicio = ahora.subtract(Duration(days: ahora.weekday % 7));
          return DateTime(inicio.year, inicio.month, inicio.day);
        }
      case PeriodoHistorial.quincenal:
        if (ahora.day <= 15) {
          return DateTime(ahora.year, ahora.month, 1);
        } else {
          return DateTime(ahora.year, ahora.month, 16);
        }
      case PeriodoHistorial.mensual:
        return DateTime(ahora.year, ahora.month, 1);
      case PeriodoHistorial.trimestral:
        final mes = ((ahora.month - 1) ~/ 3) * 3 + 1;
        return DateTime(ahora.year, mes, 1);
      case PeriodoHistorial.semestral:
        final mes = ahora.month <= 6 ? 1 : 7;
        return DateTime(ahora.year, mes, 1);
      case PeriodoHistorial.anual:
        return DateTime(ahora.year, 1, 1);
    }
  }

  List<Gasto> _filtrarPorPeriodo(List<Gasto> gastos) {
    final inicio = _inicioPeriodo(_periodoHistorial);
    return gastos
        .where((g) => g.fecha.isAfter(inicio.subtract(const Duration(days: 1))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final gastos = GastoRepository.obtenerGastos();
    final gastosFiltrados = _filtrarPorPeriodo(
      gastos,
    ); // Aplica tus filtros aquí
    final total = gastosFiltrados.fold<double>(
      0,
      (s, g) =>
          s +
          (g.montoCents != null
              ? g.montoCents! / 100.0
              : (parseMonto(g.monto) ?? 0)),
    );
    final porcentaje = _presupuesto > 0
        ? (total / _presupuesto * 100).clamp(0, 999)
        : 0;
    final sobrepasado = _presupuesto > 0 && total > _presupuesto;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.expenseHistory),
        actions: [
          PopupMenuButton<PeriodoHistorial>(
            tooltip: 'Periodo',
            icon: const Icon(Icons.calendar_month),
            onSelected: (p) => setState(() => _periodoHistorial = p),
            itemBuilder: (context) => [
              for (final p in PeriodoHistorial.values)
                PopupMenuItem(value: p, child: Text(p.localized(context))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: AppLocalizations.of(context)!.dateLabel,
            onPressed: _seleccionarFecha,
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: AppLocalizations.of(context)!.categoryLabel,
            onPressed: () => _seleccionarCategoria(gastos),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: AppLocalizations.of(context)!.budgets,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GestionPresupuestosUnificadosScreen(),
                ),
              );
              setState(() {}); // Solo refresca la pantalla al volver
            },
          ),
          if (_fechaSeleccionada != null || _categoriaSeleccionada != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: AppLocalizations.of(context)!.close,
              onPressed: () {
                setState(() {
                  _fechaSeleccionada = null;
                  _categoriaSeleccionada = null;
                });
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (gastosFiltrados.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('Periodo:'),
                          const SizedBox(width: 8),
                          DropdownButton<PeriodoHistorial>(
                            value: _periodoHistorial,
                            items: PeriodoHistorial.values
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.localized(context)),
                                  ),
                                )
                                .toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setState(() => _periodoHistorial = p);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          Text(AppLocalizations.of(context)!.chartTypeLabel),
                          const SizedBox(width: 8),
                          DropdownButton<TipoGrafico>(
                            value: _tipoGrafico,
                            items: [
                              DropdownMenuItem(
                                value: TipoGrafico.barras,
                                child: Text(
                                  AppLocalizations.of(context)!.chartBars,
                                ),
                              ),
                              DropdownMenuItem(
                                value: TipoGrafico.pastel,
                                child: Text(
                                  AppLocalizations.of(context)!.chartPie,
                                ),
                              ),
                            ],
                            onChanged: (tipo) async {
                              if (tipo != null) {
                                setState(() => _tipoGrafico = tipo);
                                await PreferenciasUsuario.guardarTipoGrafico(
                                  tipo,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Leyenda'),
                              Switch(
                                value: _mostrarLeyenda,
                                onChanged: (v) async {
                                  setState(() => _mostrarLeyenda = v);
                                  await PreferenciasUsuario.guardarMostrarLeyenda(
                                    v,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (gastosFiltrados.isNotEmpty &&
                    _tipoGrafico == TipoGrafico.barras)
                  Builder(
                    builder: (context) {
                      final Map<String, double> data = {};
                      for (var g in gastosFiltrados) {
                        final monto = g.montoCents != null
                            ? g.montoCents! / 100.0
                            : (parseMonto(g.monto) ?? 0);
                        data[g.categoria] = (data[g.categoria] ?? 0) + monto;
                      }
                      final colors = [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.red,
                        Colors.teal,
                        Colors.amber,
                        Colors.indigo,
                      ];
                      final labels = <String>[];
                      final groups = <BarChartGroupData>[];
                      int i = 0;
                      for (final e in data.entries) {
                        labels.add(e.key);
                        final color = colors[i % colors.length];
                        groups.add(
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: color,
                                width: 18,
                              ),
                            ],
                            showingTooltipIndicators: const [0],
                          ),
                        );
                        i++;
                      }
                      return SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            barGroups: groups,
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          labels[idx],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: true),
                          ),
                        ),
                      );
                    },
                  ),
                if (gastosFiltrados.isNotEmpty &&
                    _tipoGrafico == TipoGrafico.barras)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: ClipRect(
                      child: Align(
                        heightFactor: _mostrarLeyenda ? 1.0 : 0.0,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBarLegend(gastosFiltrados),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (gastosFiltrados.isNotEmpty &&
                    _tipoGrafico == TipoGrafico.pastel)
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: _crearPieSections(gastosFiltrados),
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(enabled: true),
                      ),
                    ),
                  ),
                if (gastosFiltrados.isNotEmpty &&
                    _tipoGrafico == TipoGrafico.pastel)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: ClipRect(
                      child: Align(
                        heightFactor: _mostrarLeyenda ? 1.0 : 0.0,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPieLegend(gastosFiltrados),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Period selector moved to top controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.totalLabel(formatCurrency(total))} (${_periodoHistorial.localized(context)})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCurrency(total),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sobrepasado ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_presupuesto > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${AppLocalizations.of(context)!.budgets}: ${formatCurrency(_presupuesto)} (${_periodo.localized(context)})',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (porcentaje / 100).clamp(0, 1),
                            color: sobrepasado ? Colors.red : Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${porcentaje.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: sobrepasado ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_fechaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${AppLocalizations.of(context)!.dateLabel}: ${DateFormat(dateFormatNotifier.value).format(_fechaSeleccionada!)}',
                        ),
                      ],
                    ),
                  ),
                if (_categoriaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.category, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${AppLocalizations.of(context)!.categoryLabel}: $_categoriaSeleccionada',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          FutureBuilder<Map<String, double>>(
            future: PresupuestoCategoriaRepository.obtenerTodosPorPeriodo(
              _periodo,
            ),
            builder: (context, snapshot) {
              final presupuestosCat = snapshot.data ?? {};
              final gastosPorCat = <String, double>{};
              for (var g in gastosFiltrados) {
                final monto = g.montoCents != null
                    ? g.montoCents! / 100.0
                    : (parseMonto(g.monto) ?? 0);
                gastosPorCat[g.categoria] =
                    (gastosPorCat[g.categoria] ?? 0) + monto;
              }
              if (gastosFiltrados.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noExpensesRegistered,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final gasto = gastosFiltrados[index];
                  final presupuestoCat = presupuestosCat[gasto.categoria] ?? 0;
                  final gastadoCat = gastosPorCat[gasto.categoria] ?? 0;
                  final porcentaje = presupuestoCat > 0
                      ? (gastadoCat / presupuestoCat * 100)
                      : 0;
                  Color barraColor = Colors.green;
                  if (porcentaje >= 100) {
                    barraColor = Colors.red;
                  } else if (porcentaje >= 80) {
                    barraColor = Colors.orange;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Dismissible(
                        key: Key(gasto.key.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await gasto.delete();
                          setState(() {});
                        },
                        child: ListTile(
                          leading: const Icon(Icons.monetization_on),
                          title: Text(
                            '${formatCurrency((gasto.montoCents != null ? gasto.montoCents! / 100.0 : (parseMonto(gasto.monto) ?? 0)))} - ${gasto.categoria}',
                          ),
                          subtitle: Text(
                            gasto.nota.isNotEmpty
                                ? gasto.nota
                                : AppLocalizations.of(context)!.unspecifiedName,
                          ),
                          trailing: Text(
                            DateFormat(
                              dateFormatNotifier.value,
                            ).format(gasto.fecha),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () async {
                            final actualizado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditarGastoScreen(gasto: gasto),
                              ),
                            );
                            if (actualizado == true) setState(() {});
                          },
                        ),
                      ),
                      if (presupuestoCat > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: (porcentaje / 100).clamp(0, 1),
                                color: barraColor,
                                backgroundColor: Colors.grey[300],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.budgets} ${gasto.categoria}: ${formatCurrency(gastadoCat)} / ${formatCurrency(presupuestoCat)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: barraColor,
                                    ),
                                  ),
                                  Text(
                                    '${porcentaje.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: barraColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                    ],
                  );
                }, childCount: gastosFiltrados.length),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PresupuestoScreen extends StatefulWidget {
  const PresupuestoScreen({super.key});

  @override
  State<PresupuestoScreen> createState() => _PresupuestoScreenState();
}

class _PresupuestoScreenState extends State<PresupuestoScreen> {
  final TextEditingController _controller = TextEditingController();
  double _presupuesto = 0;
  PeriodoPresupuesto _periodo = PeriodoPresupuesto.mensual;
  bool _formattingPres = false;
  late FocusNode _presupuestoFocus;

  @override
  void initState() {
    super.initState();
    _cargarPresupuesto();
    // Format on blur for presupuesto input
    _presupuestoFocus = FocusNode();
    _presupuestoFocus.addListener(() {
      if (_presupuestoFocus.hasFocus) {
        return;
      }
      if (_formattingPres) {
        return;
      }
      _formattingPres = true;
      final raw = _controller.text;
      final v = parseMonto(raw);
      if (v != null) {
        final f = formatNumberForInput(v);
        if (f != raw) {
          _controller.text = f;
          _controller.selection = TextSelection.collapsed(offset: f.length);
        }
      }
      _formattingPres = false;
    });
  }

  Future<void> _cargarPresupuesto() async {
    _controller.text = '';
    _presupuesto = await PresupuestoRepository.obtenerPresupuesto(_periodo);
    _controller.text = _presupuesto > 0
        ? formatNumberForInput(_presupuesto)
        : '';
    setState(() {});
  }

  Future<void> _guardar() async {
    final valor = parseMonto(_controller.text) ?? 0;
    await PresupuestoRepository.guardarPresupuesto(valor, _periodo);
    if (!mounted) {
      return;
    }
    Navigator.pop(context, {'monto': valor, 'periodo': _periodo});
  }

  @override
  void dispose() {
    _controller.dispose();
    _presupuestoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.budgets)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.defineBudgetByCategory,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _presupuestoFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
                prefixIcon: const Icon(Icons.account_balance_wallet),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PeriodoPresupuesto>(
              initialValue: _periodo,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.periodMonthly,
                border: const OutlineInputBorder(),
              ),
              items: PresupuestoRepository.periodos
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.localized(context)),
                    ),
                  )
                  .toList(),
              onChanged: (p) async {
                if (p != null) {
                  setState(() => _periodo = p);
                  _presupuesto = await PresupuestoRepository.obtenerPresupuesto(
                    _periodo,
                  );
                  _controller.text = _presupuesto > 0
                      ? formatNumberForInput(_presupuesto)
                      : '';
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)!.save),
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Pantalla de gestión de presupuestos múltiples ---
class GestionPresupuestosScreen extends StatefulWidget {
  const GestionPresupuestosScreen({super.key});

  @override
  State<GestionPresupuestosScreen> createState() =>
      _GestionPresupuestosScreenState();
}

class _GestionPresupuestosScreenState extends State<GestionPresupuestosScreen> {
  final Map<PeriodoPresupuesto, TextEditingController> _controllers = {};
  Map<PeriodoPresupuesto, double> _valores = {};
  bool _cargando = true;
  Map<PeriodoPresupuesto, FocusNode>? _focusNodesForControllers;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _valores = await PresupuestoRepository.obtenerTodos();
    for (var p in PresupuestoRepository.periodos) {
      final ctrl = TextEditingController(
        text: _valores[p] != null ? formatNumberForInput(_valores[p]!) : '',
      );
      // format on blur: create a FocusNode per controller and attach a blur listener
      final focus = FocusNode();
      focus.addListener(() {
        if (focus.hasFocus) {
          return;
        }
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
      // store focus node on the controller via a helper map so we can dispose later
      _controllers[p] = ctrl;
      // store focus nodes for disposal
      _focusNodesForControllers ??= {};
      _focusNodesForControllers![p] = focus;
    }
    setState(() => _cargando = false);
  }

  Future<void> _guardar(PeriodoPresupuesto p) async {
    final valor = parseMonto(_controllers[p]?.text ?? '') ?? 0;
    await PresupuestoRepository.guardarPresupuesto(valor, p);
    if (!mounted) {
      return;
    }
    setState(() => _valores[p] = valor);
    final savedMsg = AppLocalizations.of(context)!.saved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$savedMsg ${p.localized(context)}')),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    if (_focusNodesForControllers != null) {
      for (var f in _focusNodesForControllers!.values) {
        f.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.savedBudgets)),
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
                  ...PresupuestoRepository.periodos.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              p.localized(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _controllers[p],
                              focusNode: _focusNodesForControllers?[p],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.amount,
                                prefixIcon: const Icon(
                                  Icons.account_balance_wallet,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _guardar(p),
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
