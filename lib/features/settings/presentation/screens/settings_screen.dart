import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/theme_settings.dart';
import '../../domain/entities/currency_settings.dart';
import '../../domain/entities/date_settings.dart';
import '../../providers/settings_providers.dart';

/// Modern Settings Screen following Clean Architecture
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetToDefaults(context),
            tooltip: 'Restablecer configuración',
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error, stack),
        data: (settings) => _buildSettingsContent(context, settings),
      ),
    );
  }

  Widget _buildErrorWidget(Object error, StackTrace stack) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar la configuración',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(error.toString()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(settingsProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemeSection(context, settings.theme),
        const SizedBox(height: 16),
        _buildCurrencySection(context, settings.currency),
        const SizedBox(height: 16),
        _buildDateSection(context, settings.date),
        const SizedBox(height: 16),
        _buildCategoriesSection(context, settings.customCategories),
        const SizedBox(height: 16),
        _buildGeneralSection(context, settings.general),
        const SizedBox(height: 16),
        _buildDataSection(context),
        const SizedBox(height: 16),
        _buildAboutSection(context),
      ],
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeSettings theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Tema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThemeModeSelector(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(ThemeSettings theme) {
    return Column(
      children: [
        ListTile(
          title: const Text('Sistema'),
          subtitle: const Text('Seguir configuración del sistema'),
          leading: Radio<ThemeMode>(
            value: ThemeMode.system,
            // ignore: deprecated_member_use
            groupValue: theme.themeMode,
            // ignore: deprecated_member_use
            onChanged: (value) => _updateThemeMode(value!),
          ),
          onTap: () => _updateThemeMode(ThemeMode.system),
        ),
        ListTile(
          title: const Text('Claro'),
          subtitle: const Text('Tema claro siempre'),
          leading: Radio<ThemeMode>(
            value: ThemeMode.light,
            // ignore: deprecated_member_use
            groupValue: theme.themeMode,
            // ignore: deprecated_member_use
            onChanged: (value) => _updateThemeMode(value!),
          ),
          onTap: () => _updateThemeMode(ThemeMode.light),
        ),
        ListTile(
          title: const Text('Oscuro'),
          subtitle: const Text('Tema oscuro siempre'),
          leading: Radio<ThemeMode>(
            value: ThemeMode.dark,
            // ignore: deprecated_member_use
            groupValue: theme.themeMode,
            // ignore: deprecated_member_use
            onChanged: (value) => _updateThemeMode(value!),
          ),
          onTap: () => _updateThemeMode(ThemeMode.dark),
        ),
      ],
    );
  }

  Widget _buildCurrencySection(BuildContext context, CurrencySettings currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Moneda',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCurrencyPresets(currency),
            const SizedBox(height: 16),
            _buildCurrencyCustomization(currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPresets(CurrencySettings currency) {
    final presets = CurrencySettings.presets;
    final presetNames = ['USD', 'EUR', 'MXN', 'COP'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monedas predefinidas:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(presets.length, (index) {
            final preset = presets[index];
            final name = presetNames[index];
            final isSelected = currency.symbol == preset.symbol;
            return ChoiceChip(
              label: Text('${preset.symbol} $name'),
              selected: isSelected,
              onSelected: (_) => _updateCurrencySettings(preset),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrencyCustomization(CurrencySettings currency) {
    return Column(
      children: [
        ListTile(
          title: const Text('Símbolo de moneda'),
          subtitle: Text(currency.symbol),
          trailing: const Icon(Icons.edit),
          onTap: () => _editCurrencySymbol(currency),
        ),
        ListTile(
          title: const Text('Separador decimal'),
          subtitle: Text(currency.decimalSeparator),
          trailing: const Icon(Icons.edit),
          onTap: () => _editDecimalSeparator(currency),
        ),
        ListTile(
          title: const Text('Separador de miles'),
          subtitle: Text(currency.thousandSeparator),
          trailing: const Icon(Icons.edit),
          onTap: () => _editThousandSeparator(currency),
        ),
        ListTile(
          title: const Text('Decimales'),
          subtitle: Text('${currency.decimalPlaces} dígitos'),
          trailing: DropdownButton<int>(
            value: currency.decimalPlaces,
            items: [0, 1, 2, 3, 4].map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: (value) => _updateDecimalPlaces(currency, value!),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.preview),
              const SizedBox(width: 8),
              Text('Ejemplo: ${currency.formatAmount(1234.56)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, DateSettings date) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Fecha y Hora',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Formato de fecha'),
              subtitle: Text(date.dateFormat),
              trailing: const Icon(Icons.edit),
              onTap: () => _editDateFormat(date),
            ),
            ListTile(
              title: const Text('Inicio de semana'),
              subtitle: Text(date.weekStart == WeekStart.monday ? 'Lunes' : 'Domingo'),
              trailing: DropdownButton<WeekStart>(
                value: date.weekStart,
                items: WeekStart.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value == WeekStart.monday ? 'Lunes' : 'Domingo'),
                  );
                }).toList(),
                onChanged: (value) => _updateWeekStart(date, value!),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.preview),
                  const SizedBox(width: 8),
                  Text('Ejemplo: ${_formatDate(DateTime.now(), date.dateFormat)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, List<String> categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Categorías Personalizadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Text('No hay categorías personalizadas')
            else
              ...categories.map((category) => ListTile(
                title: Text(category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeCategory(category),
                ),
              )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Categoría'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context, GeneralSettings general) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'General',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Respaldo automático'),
              subtitle: Text('Cada ${general.backupFrequencyDays} días'),
              value: general.autoBackup,
              onChanged: (value) => _updateAutoBackup(general, value),
            ),
            SwitchListTile(
              title: const Text('Notificaciones'),
              subtitle: const Text('Recordatorios y alertas'),
              value: general.enableNotifications,
              onChanged: (value) => _updateNotifications(general, value),
            ),
            ListTile(
              title: const Text('Frecuencia de respaldo'),
              subtitle: Text('${general.backupFrequencyDays} días'),
              trailing: DropdownButton<int>(
                value: general.backupFrequencyDays,
                items: [1, 3, 7, 14, 30].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value días'),
                  );
                }).toList(),
                onChanged: (value) => _updateBackupFrequency(general, value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Datos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Exportar configuración'),
              subtitle: const Text('Guardar configuración en archivo'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _exportSettings,
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Importar configuración'),
              subtitle: const Text('Cargar configuración desde archivo'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _importSettings,
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Migrar configuración'),
              subtitle: const Text('Actualizar desde versión anterior'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _migrateLegacySettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final appInfoAsync = ref.watch(appInfoProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Acerca de',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            appInfoAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error al cargar información'),
              data: (appInfo) => Column(
                children: [
                  ListTile(
                    title: const Text('Nombre de la app'),
                    subtitle: Text(appInfo['appName'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: const Text('Versión'),
                    subtitle: Text(appInfo['version'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: const Text('Build'),
                    subtitle: Text(appInfo['buildNumber'] ?? 'N/A'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _updateThemeMode(ThemeMode mode) {
    final notifier = ref.read(settingsProvider.notifier);
    final newTheme = ThemeSettings(themeMode: mode);
    notifier.updateThemeSettings(newTheme);
  }

  void _updateCurrencySettings(CurrencySettings currency) {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateCurrencySettings(currency);
  }

  void _updateDecimalPlaces(CurrencySettings current, int places) {
    final updated = current.copyWith(decimalPlaces: places);
    _updateCurrencySettings(updated);
  }

  void _updateWeekStart(DateSettings current, WeekStart start) {
    final updated = current.copyWith(weekStart: start);
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateDateSettings(updated);
  }

  void _updateAutoBackup(GeneralSettings current, bool enabled) {
    final updated = current.copyWith(autoBackup: enabled);
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateGeneralSettings(updated);
  }

  void _updateNotifications(GeneralSettings current, bool enabled) {
    final updated = current.copyWith(enableNotifications: enabled);
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateGeneralSettings(updated);
  }

  void _updateBackupFrequency(GeneralSettings current, int days) {
    final updated = current.copyWith(backupFrequencyDays: days);
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateGeneralSettings(updated);
  }

  void _removeCategory(String category) {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.removeCustomCategory(category);
  }

  // Dialog methods
  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        onAdd: (category) {
          final notifier = ref.read(settingsProvider.notifier);
          notifier.addCustomCategory(category);
        },
      ),
    );
  }

  void _editCurrencySymbol(CurrencySettings current) {
    showDialog(
      context: context,
      builder: (context) => _TextEditDialog(
        title: 'Símbolo de moneda',
        initialValue: current.symbol,
        onSave: (value) {
          final updated = current.copyWith(symbol: value);
          _updateCurrencySettings(updated);
        },
      ),
    );
  }

  void _editDecimalSeparator(CurrencySettings current) {
    showDialog(
      context: context,
      builder: (context) => _TextEditDialog(
        title: 'Separador decimal',
        initialValue: current.decimalSeparator,
        maxLength: 1,
        onSave: (value) {
          final updated = current.copyWith(decimalSeparator: value);
          _updateCurrencySettings(updated);
        },
      ),
    );
  }

  void _editThousandSeparator(CurrencySettings current) {
    showDialog(
      context: context,
      builder: (context) => _TextEditDialog(
        title: 'Separador de miles',
        initialValue: current.thousandSeparator,
        maxLength: 1,
        onSave: (value) {
          final updated = current.copyWith(thousandSeparator: value);
          _updateCurrencySettings(updated);
        },
      ),
    );
  }

  void _editDateFormat(DateSettings current) {
    final formats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd-MM-yyyy'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Formato de fecha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return ListTile(
              title: Text(format),
              subtitle: Text(_formatDate(DateTime.now(), format)),
              leading: Radio<String>(
                value: format,
                // ignore: deprecated_member_use
                groupValue: current.dateFormat,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  Navigator.pop(context);
                  final updated = current.copyWith(dateFormat: value!);
                  final notifier = ref.read(settingsProvider.notifier);
                  notifier.updateDateSettings(updated);
                },
              ),
              onTap: () {
                Navigator.pop(context);
                final updated = current.copyWith(dateFormat: format);
                final notifier = ref.read(settingsProvider.notifier);
                notifier.updateDateSettings(updated);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _exportSettings() async {
    try {
      final notifier = ref.read(settingsProvider.notifier);
      final export = await notifier.exportSettings();
      final json = jsonEncode(export);
      
      // ignore: deprecated_member_use
      await Share.share(
        json,
        subject: 'Configuración de Luz en el Gasto',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  void _importSettings() async {
    try {
      // Simplified import - just show success message
      // In a real app, you'd use file_picker package
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad de importación no disponible')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }

  void _migrateLegacySettings() async {
    try {
      final notifier = ref.read(settingsProvider.notifier);
      await notifier.migrateLegacySettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Migración completada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en migración: $e')),
        );
      }
    }
  }

  void _resetToDefaults(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer toda la configuración a los valores predeterminados? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final notifier = ref.read(settingsProvider.notifier);
              notifier.resetToDefaults();
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date, String format) {
    // Simple date formatting without external dependencies
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-MM-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default:
        return date.toString().split(' ')[0];
    }
  }
}

// Helper dialog widgets
class _CategoryDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _CategoryDialog({required this.onAdd});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar categoría'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nombre de la categoría',
          hintText: 'Ej: Entretenimiento',
        ),
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onAdd(value);
      Navigator.pop(context);
    }
  }
}

class _TextEditDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final Function(String) onSave;
  final int? maxLength;

  const _TextEditDialog({
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.maxLength,
  });

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: widget.maxLength,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onSave(value);
      Navigator.pop(context);
    }
  }
}