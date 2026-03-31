import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// New ads feature import
import '../../../ads/presentation/widgets/ad_banner_widget.dart';
import '../../../ads/domain/entities/ad_banner.dart' as domain;
import '../../../ads/presentation/providers/ad_banner_providers.dart';

// Feature imports - using legacy screens temporarily during migration
import '../../../expenses/presentation/screens/registro_gasto_screen.dart';
import '../../../expenses/presentation/screens/expense_error_demo_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../../gestion_presupuestos_unificados_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

// Localization
import '../../../../l10n/app_localizations.dart';

/// Main menu screen with navigation to all app features
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    _setupDefaultBanners();
  }

  Future<void> _setupDefaultBanners() async {
    try {
      // Setup banners using the new ads feature
      final setupUseCase = ref.read(setupDefaultBannersProvider);
      await setupUseCase();
    } catch (e) {
      debugPrint('Error setting up banners: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuButton(
              context: context,
              icon: Icons.add_circle_outline,
              label: AppLocalizations.of(context)!.registerExpense,
              onPressed: () => _navigateToExpenseRegistration(),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context: context,
              icon: Icons.bar_chart,
              label: AppLocalizations.of(context)!.expenseHistory,
              onPressed: () => _navigateToAnalytics(),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context: context,
              icon: Icons.account_balance_wallet,
              label: AppLocalizations.of(context)!.budgets,
              onPressed: () => _navigateToBudgets(),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context: context,
              icon: Icons.settings,
              label: AppLocalizations.of(context)!.settings,
              onPressed: () => _navigateToSettings(),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context: context,
              icon: Icons.bug_report,
              label: '🛡️ Demo: Error Handling',
              onPressed: () => _navigateToErrorDemo(),
            ),
          ],
        ),
      ),
      // Banner at the bottom of the screen using new ads feature
      bottomNavigationBar: AdBannerWidget.forPosition(
        position: domain.AdBannerPosition.bottom,
        height: 85,
        margin: EdgeInsets.zero,
        showLoadingIndicator: false,
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }

  void _navigateToExpenseRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroGastoScreen(),
      ),
    );
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _navigateToBudgets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GestionPresupuestosUnificadosScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToErrorDemo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseErrorHandlingDemo(),
      ),
    );
  }
}