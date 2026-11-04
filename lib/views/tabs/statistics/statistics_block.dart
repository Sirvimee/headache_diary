import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/pdf/statistics_pdf_service.dart';
import '../../../state/statistics/statistics_shared.dart';
import '../../../state/auth/backend/local_storage.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class StatisticsBlock extends StatefulWidget {
  final Map<String, String> block;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  StatisticsBlock({
    super.key,
    required this.block,
    this.periodStart,
    this.periodEnd,
  });

  @override
  State<StatisticsBlock> createState() => _StatisticsBlockState();
}

class _StatisticsBlockState extends State<StatisticsBlock> {
  bool _exporting = false;
  late List<_SummaryRow> _rows;
  Set<String> _hiddenRows = {};

  static const _defaultRows = [
    _SummaryRow('headacheDays', Strings.headacheDays),
    _SummaryRow('rightSide', Strings.rightSideHeadaches),
    _SummaryRow('leftSide', Strings.leftSideHeadaches),
    _SummaryRow('overhead', Strings.overheadHeadaches),
    _SummaryRow('pills', Strings.pillsTaken),
    _SummaryRow('systal', Strings.injectionsMade),
    _SummaryRow('run', Strings.cardioDays),
    _SummaryRow('strength', Strings.strengthDays),
    _SummaryRow('sex', Strings.intercourseDays),
    _SummaryRow('alcohol', Strings.alcoholDays),
    _SummaryRow('menstruation', Strings.menstruationDays),
    _SummaryRow('chocolate', Strings.chocolateDays),
    _SummaryRow('doctor', Strings.doctorVisits),
    _SummaryRow('eyePain', Strings.eyePainDays),
    _SummaryRow('vomit', Strings.vomitingDays),
    _SummaryRow('preventivePill', Strings.preventivePillDays),
  ];

  @override
  void initState() {
    super.initState();
    _rows = List.of(_defaultRows);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = LocalStorage.summarySettings;
    final savedOrder = (settings['order'] as List?)?.cast<String>() ?? [];
    final savedHidden = (settings['hidden'] as List?)?.cast<String>() ?? [];
    final byKey = {for (final row in _defaultRows) row.key: row};
    final ordered = <_SummaryRow>[
      for (final key in savedOrder)
        if (byKey[key] != null) byKey[key]!,
    ];
    ordered.addAll(_defaultRows.where((row) => !savedOrder.contains(row.key)));
    if (mounted) {
      setState(() {
        _rows = ordered;
        _hiddenRows = savedHidden.toSet();
      });
    }
  }

  Future<void> _saveSettings() {
    return LocalStorage.saveSummarySettings({
      'order': _rows.map((row) => row.key).toList(),
      'hidden': _hiddenRows.toList(),
    });
  }

  Future<void> _configureSummary() async {
    var rows = List.of(_rows);
    var hidden = Set<String>.of(_hiddenRows);
    final result = await showDialog<({List<_SummaryRow> rows, Set<String> hidden})>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(Strings.configureSummary),
          content: SizedBox(
            width: double.maxFinite,
            height: 480,
            child: ReorderableListView.builder(
              itemCount: rows.length,
              onReorder: (oldIndex, newIndex) {
                setDialogState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final row = rows.removeAt(oldIndex);
                  rows.insert(newIndex, row);
                });
              },
              itemBuilder: (context, index) {
                final row = rows[index];
                return CheckboxListTile(
                  key: ValueKey(row.key),
                  value: !hidden.contains(row.key),
                  activeColor: AppColors.buttonColor,
                  checkColor: AppColors.primaryColor,
                  title: Text(
                    row.label,
                    style: TextStyle(color: AppColors.buttonColor),
                  ),
                  subtitle: Text(
                    'Lohista rea järjekorra muutmiseks',
                    style: TextStyle(color: AppColors.hintColor),
                  ),
                  onChanged: (value) => setDialogState(() {
                    if (value == true) {
                      hidden.remove(row.key);
                    } else {
                      hidden.add(row.key);
                    }
                  }),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => setDialogState(() {
                rows = List.of(_defaultRows);
                hidden.clear();
              }),
              child: Text(
                Strings.resetSummarySettings,
                style: TextStyle(color: AppColors.buttonColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                (rows: rows, hidden: hidden),
              ),
              child: Text(
                Strings.saveSummarySettings,
                style: TextStyle(color: AppColors.buttonColor),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _rows = result.rows;
      _hiddenRows = result.hidden;
    });
    await _saveSettings();
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.buttonColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final start = widget.periodStart;
    final end = widget.periodEnd;
    if (start == null || end == null || _exporting) return;

    setState(() => _exporting = true);
    try {
      final notes = await fetchNotesForPeriod(start, end);
      final userName = FirebaseAuth.instance.currentUser?.displayName;

      await StatisticsPdfService.exportAndShare(
        block: widget.block,
        start: start,
        end: end,
        userName: userName,
        notes: notes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Strings.pdfExportFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExport = widget.periodStart != null && widget.periodEnd != null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.block['title'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                tooltip: Strings.configureSummary,
                onPressed: _configureSummary,
                icon: Icon(
                  Icons.tune,
                  color: AppColors.buttonColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          for (final row in _rows)
            if (!_hiddenRows.contains(row.key))
              _row(row.label, widget.block[row.key] ?? '-'),
          if (canExport) ...[
            SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _exporting ? null : _exportPdf,
              icon: _exporting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.buttonColor,
                      ),
                    )
                  : Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.buttonColor,
                    ),
              label: Text(
                _exporting ? Strings.pdfExporting : Strings.exportPdf,
                style: TextStyle(color: AppColors.buttonColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.buttonColor),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String key;
  final String label;

  const _SummaryRow(this.key, this.label);
}
