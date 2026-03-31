import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/expense_providers.dart';
import '../../../../shared/utils/format_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/ad_banner.dart';
import '../../../../services/ad_banner_service.dart';

class RegistroGastoScreen extends ConsumerStatefulWidget {
  const RegistroGastoScreen({super.key});

  @override
  ConsumerState<RegistroGastoScreen> createState() => _RegistroGastoScreenState();
}

class _RegistroGastoScreenState extends ConsumerState<RegistroGastoScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  AdBannerConfig _banner2Config = const AdBannerConfig(isEnabled: false);
  
  late FocusNode _montoFocus;
  bool _formattingMonto = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadBannerConfig();
    
    _montoFocus = FocusNode();
    _montoFocus.addListener(() {
      if (_montoFocus.hasFocus || _formattingMonto) return;
      
      _formattingMonto = true;
      final raw = _montoController.text;
      final v = parseMonto(raw);
      if (v != null) {
        final f = formatNumberForInput(v);
        if (f != raw) {
          _montoController.text = f;
          _montoController.selection = TextSelection.collapsed(offset: f.length);
        }
      }
      _formattingMonto = false;
    });
  }

  Future<void> _loadBannerConfig() async {
    setState(() {
      _banner2Config = const AdBannerConfig(
        isEnabled: true,
        fallbackText: '🍕 Delivery Gratis en tu Primera Orden - App Food',
        targetUrl: 'https://dart.dev',
        imageUrl: 'https://picsum.photos/350/70?random=2',
      );
    });
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
    final montoRegExp = RegExp(r'(\\d{1,}[\\.,]?\\d{0,})');
    final categoriaRegExp = RegExp(
      r'en ([a-zA-ZáéíóúÁÉÍÓÚñÑ ]+)',
      caseSensitive: false,
    );
    String monto = '';
    String categoria = '';

    final parsedByHelper = parseMonto(text);
    if (parsedByHelper != null) {
      monto = formatNumberForInput(parsedByHelper);
    } else {
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

  void _guardarGasto() async {
    if (_montoController.text.isNotEmpty && _categoriaController.text.isNotEmpty) {
      final montoGasto = parseMonto(_montoController.text) ?? 0;
      
      // Create expense using the form notifier
      final formNotifier = ref.read(expenseFormProvider.notifier);
      formNotifier.updateDescription(_notaController.text);
      formNotifier.updateAmount(montoGasto);
      formNotifier.updateCategory(_categoriaController.text);
      
      // Check if form is valid by reading the current state
      final formState = ref.read(expenseFormProvider);
      if (formState.isValid) {
        final expense = formNotifier.toExpense();
        
        // Add expense using the provider
        final expensesNotifier = ref.read(expensesProvider.notifier);
        await expensesNotifier.addExpense(expense);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.saveExpense),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pleaseEnterAmountAndCategory),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
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
              // Banner 2 - Registration page
              if (_banner2Config.isEnabled)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: AdBanner(
                    imageUrl: _banner2Config.imageUrl,
                    targetUrl: _banner2Config.targetUrl,
                    localImagePath: _banner2Config.localImagePath,
                    fallbackText: _banner2Config.fallbackText,
                  ),
                ),
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
}
