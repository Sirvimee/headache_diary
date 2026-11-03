import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../views/constants/strings.dart';

class DayNoteEntry {
  final String date;
  final String note;

  const DayNoteEntry({required this.date, required this.note});
}

class StatisticsPdfService {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _generatedFormat = DateFormat('dd.MM.yyyy HH:mm');
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<pw.Font> _regular() async {
    _regularFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    return _regularFont!;
  }

  static Future<pw.Font> _bold() async {
    _boldFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    return _boldFont!;
  }

  static Future<void> exportAndShare({
    required Map<String, String> block,
    required DateTime start,
    required DateTime end,
    String? userName,
    List<DayNoteEntry> notes = const [],
  }) async {
    final pdf = await _buildDocument(
      block: block,
      start: start,
      end: end,
      userName: userName,
      notes: notes,
    );

    final filename =
        '${Strings.pdfFilenamePrefix}_${_dateFormat.format(start)}_${_dateFormat.format(end)}.pdf';
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }

  static Future<pw.Document> _buildDocument({
    required Map<String, String> block,
    required DateTime start,
    required DateTime end,
    String? userName,
    required List<DayNoteEntry> notes,
  }) async {
    final regular = await _regular();
    final bold = await _bold();

    final periodLabel = start.year == end.year && start.month == end.month && start.day == end.day
        ? _dateFormat.format(start)
        : '${_dateFormat.format(start)} – ${_dateFormat.format(end)}';

    final doc = pw.Document(
      title: Strings.pdfReportTitle,
      author: userName ?? Strings.appName,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(Strings.pdfReportTitle, style: pw.TextStyle(font: bold, fontSize: 22)),
          pw.SizedBox(height: 8),
          if (userName != null && userName.isNotEmpty) ...[
            pw.Text('${Strings.pdfUserLabel}: $userName', style: pw.TextStyle(font: regular, fontSize: 12)),
            pw.SizedBox(height: 4),
          ],
          pw.Text('${Strings.pdfPeriodLabel}: $periodLabel', style: pw.TextStyle(font: regular, fontSize: 12)),
          pw.Text(
            '${Strings.pdfGeneratedLabel}: ${_generatedFormat.format(DateTime.now())}',
            style: pw.TextStyle(font: regular, fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            Strings.pdfSymptomsSection,
            style: pw.TextStyle(font: bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          _row(regular, Strings.headacheDays, block['headacheDays'] ?? '-'),
          _row(regular, Strings.rightSideHeadaches, block['rightSide'] ?? '-', indent: 12),
          _row(regular, Strings.leftSideHeadaches, block['leftSide'] ?? '-', indent: 12),
          _row(regular, Strings.overheadHeadaches, block['overhead'] ?? '-', indent: 12),
          _row(regular, Strings.eyePainDays, block['eyePain'] ?? '-'),
          _row(regular, Strings.vomitingDays, block['vomit'] ?? '-'),
          pw.SizedBox(height: 16),
          pw.Text(
            Strings.pdfMedicationMonitoringSection,
            style: pw.TextStyle(font: bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          _row(regular, Strings.pillsTaken, block['pills'] ?? '-'),
          _row(regular, Strings.injectionsMade, block['systal'] ?? '-'),
          _row(
            regular,
            Strings.preventivePillDays,
            block['preventivePill'] ?? '-',
          ),
          _row(regular, Strings.doctorVisits, block['doctor'] ?? '-'),
          pw.SizedBox(height: 16),
          pw.Text(
            Strings.pdfBiologySection,
            style: pw.TextStyle(font: bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          _row(regular, Strings.menstruationDays, block['menstruation'] ?? '-'),
          pw.SizedBox(height: 16),
          pw.Text(
            Strings.pdfTriggersSection,
            style: pw.TextStyle(font: bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          _subsection(bold, Strings.pdfPhysicalActivitySubsection),
          _row(regular, Strings.cardioDays, block['run'] ?? '-', indent: 12),
          _row(regular, Strings.strengthDays, block['strength'] ?? '-', indent: 12),
          _subsection(bold, Strings.pdfNutritionHabitsSubsection),
          _row(regular, Strings.alcoholDays, block['alcohol'] ?? '-', indent: 12),
          _row(regular, Strings.chocolateDays, block['chocolate'] ?? '-', indent: 12),
          _subsection(bold, Strings.pdfOtherActivitySubsection),
          _row(regular, Strings.intercourseDays, block['sex'] ?? '-', indent: 12),
          if (notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(Strings.pdfNotesSection, style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            ...notes.map(
              (entry) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(entry.date, style: pw.TextStyle(font: bold, fontSize: 11)),
                    pw.Text(entry.note, style: pw.TextStyle(font: regular, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _subsection(pw.Font font, String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
      child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
    );
  }

  static pw.Widget _row(
    pw.Font font,
    String label,
    String value, {
    double indent = 0,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(left: indent, bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              '• $label',
              style: pw.TextStyle(font: font, fontSize: 11),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
