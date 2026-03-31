import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Legacy compatibility - TODO: Remove when migration is complete
import 'legacy_gasto_repository.dart';

// Feature imports
import 'features/settings/providers/settings_providers.dart';

// Presentation imports
import 'features/home/presentation/screens/main_menu_screen.dart';
import 'l10n/app_localizations.dart';

/// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize legacy repositories - TODO: Remove when migration complete
  await GastoRepository.init();
  
  runApp(
    const ProviderScope(
      child: LuzEnElGastoApp(),
    ),
  );
}

/// Main application widget with theme and localization
class LuzEnElGastoApp extends ConsumerWidget {
  const LuzEnElGastoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return settingsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          ),
        ),
      ),
      data: (settings) => MaterialApp(
        title: 'Luz en el Gasto',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration from settings
        themeMode: settings.theme.themeMode,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        
        // Localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settings.locale.languageCode),
        
        // Navigation
        home: const MainMenuScreen(),
      ),
    );
  }
}