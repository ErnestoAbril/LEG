import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'shared/utils/format_utils.dart';

/// Export all presupuestos to a simple PDF and return the file path.
Future<String> exportAllPresupuestosToPdf(
  List<Map<String, dynamic>> presupuestos,
) async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      build: (context) {
        return presupuestos.map((p) {
          final cats = (p['categorias'] as Map<String, dynamic>).entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n');
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                p['nombre'] ?? '',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('${p['tipo'] ?? ''}'),
              pw.SizedBox(height: 6),
              pw.Text(cats),
              pw.Divider(),
            ],
          );
        }).toList();
      },
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/presupuestos_export.pdf');
  await file.writeAsBytes(await doc.save());
  return file.path;
}

/// Export the presupuestos list to an Excel file and return the file path.
Future<String> exportAllPresupuestosToExcel(
  List<Map<String, dynamic>> presupuestos,
) async {
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];
  // header
  sheet.appendRow(['Nombre', 'Tipo', 'Categorias']);
  for (var p in presupuestos) {
    final cats = (p['categorias'] as Map<String, dynamic>).entries
        .map((e) => '${e.key}:${e.value}')
        .join('; ');
    sheet.appendRow([p['nombre'] ?? '', p['tipo'] ?? '', cats]);
  }
  final bytes = excel.encode();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/presupuestos_export.xlsx');
  if (bytes == null) throw Exception('Failed to generate excel bytes');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<void> shareFile(String path, {String? mimeType}) async {
  // ignore: deprecated_member_use
  await Share.shareXFiles([XFile(path)], text: 'Compartiendo archivo');
}

/// Generate a PDF dashboard with simple bar chart-like visuals and summaries.
Future<String> exportDashboardPdfFromData(
  List<Map<String, dynamic>> gastos,
  List<Map<String, dynamic>> presupuestos,
  String title, {
  String chartType = 'bar',
}) async {
  final doc = pw.Document();

  // aggregate by category
  final Map<String, double> byCat = {};
  double total = 0;
  for (var g in gastos) {
    double monto = 0;
    // Preferir un campo canónico en centavos si está disponible
    if (g.containsKey('montoCents') && g['montoCents'] != null) {
      try {
        monto = (g['montoCents'] as num).toDouble() / 100.0;
      } catch (_) {
        monto = 0;
      }
    } else if (g.containsKey('monto')) {
      monto = parseMonto(g['monto']?.toString() ?? '') ?? 0;
    }
    final cat = (g['categoria'] as String?) ?? 'Otros';
    byCat[cat] = (byCat[cat] ?? 0) + monto;
    total += monto;
  }

  final sorted = byCat.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  doc.addPage(
    pw.MultiPage(
      pageFormat: pdf.PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Dashboard — $title',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Resumen general',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total gastos: ${NumberFormat.simpleCurrency(locale: 'es').format(total)}',
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Top categorías',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          // build chart: bar or pie
          if (chartType == 'bar') ...[
            ...sorted.map((e) {
              final widthFactor = total > 0 ? (e.value / total) : 0.0;
              final barWidth = (widthFactor * 300).clamp(10, 300).toDouble();
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(e.key),
                      pw.Text(
                        NumberFormat.simpleCurrency(
                          locale: 'es',
                        ).format(e.value),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    width: barWidth,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: pdf.PdfColor.fromInt(0xff7b1fa2),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],
              );
            }),
          ] else ...[
            // simple pie: list entries with percentage and small circle
            ...sorted.map((e) {
              final pct = total > 0 ? (e.value / total) * 100 : 0.0;
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 12,
                        height: 12,
                        decoration: pw.BoxDecoration(
                          color: pdf.PdfColor.fromInt(0xff7b1fa2),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(e.key),
                    ],
                  ),
                  pw.Text(
                    '${pct.toStringAsFixed(1)}%  ${NumberFormat.simpleCurrency(locale: 'es').format(e.value)}',
                  ),
                ],
              );
            }),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Presupuestos incluidos',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            border: null,
            data: <List<String>>[
              ['Nombre', 'Tipo', 'Total Categorías'],
              ...presupuestos.map((p) {
                final cats = (p['categorias'] as Map<String, dynamic>?) ?? {};
                final totalPres = cats.values.fold<double>(
                  0,
                  (a, b) => a + (b as num).toDouble(),
                );
                return <String>[
                  p['nombre']?.toString() ?? '',
                  p['tipo']?.toString() ?? '',
                  NumberFormat.simpleCurrency(locale: 'es').format(totalPres),
                ];
              }),
            ],
          ),
        ];
      },
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
  await file.writeAsBytes(await doc.save(), flush: true);
  return file.path;
}

/// Export expenses and budgets into an Excel workbook with two sheets.
Future<String> exportExpensesAndBudgetsExcelFromData(
  List<Map<String, dynamic>> gastos,
  List<Map<String, dynamic>> presupuestos,
) async {
  final excel = Excel.createExcel();
  final Sheet gastosSheet = excel['Gastos'];
  gastosSheet.appendRow([
    'Fecha',
    'Monto',
    'Categoría',
    'Nota',
    'PresupuestoId',
  ]);
  final DateFormat df = DateFormat('yyyy-MM-dd HH:mm');
  for (var g in gastos) {
    final fecha = (g['fecha'] is DateTime)
        ? g['fecha'] as DateTime
        : DateTime.tryParse(g['fecha'].toString()) ?? DateTime.now();
    gastosSheet.appendRow([
      df.format(fecha),
      g['monto'] ?? '',
      g['categoria'] ?? '',
      g['nota'] ?? '',
      g['presupuestoId']?.toString() ?? '',
    ]);
  }

  final Sheet presSheet = excel['Presupuestos'];
  presSheet.appendRow(['Nombre', 'Tipo', 'Categoria', 'Monto']);
  for (var p in presupuestos) {
    final cats = (p['categorias'] as Map<String, dynamic>?) ?? {};
    cats.forEach((k, v) {
      presSheet.appendRow([
        p['nombre'] ?? '',
        p['tipo'] ?? '',
        k,
        (v as num).toString(),
      ]);
    });
  }

  final bytes = excel.encode();
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/gastos_presupuestos_${DateTime.now().millisecondsSinceEpoch}.xlsx',
  );
  if (bytes == null) throw Exception('Failed to generate excel bytes');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
