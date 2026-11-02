import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/pdf/statistics_pdf_service.dart';
import '../../../state/statistics/statistics_shared.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class StatisticsBlock extends StatefulWidget {
  final Map<String, String> block;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const StatisticsBlock({
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.buttonColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              widget.block['title'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _row(Strings.headacheDays, widget.block['headacheDays'] ?? '-'),
          _row(Strings.rightSideHeadaches, widget.block['rightSide'] ?? '-'),
          _row(Strings.leftSideHeadaches, widget.block['leftSide'] ?? '-'),
          _row(Strings.overheadHeadaches, widget.block['overhead'] ?? '-'),
          const SizedBox(height: 16),
          _row(Strings.pillsTaken, widget.block['pills'] ?? '-'),
          _row(Strings.injectionsMade, widget.block['systal'] ?? '-'),
          const SizedBox(height: 16),
          _row(Strings.cardioDays, widget.block['run'] ?? '-'),
          _row(Strings.strengthDays, widget.block['strength'] ?? '-'),
          _row(Strings.intercourseDays, widget.block['sex'] ?? '-'),
          const SizedBox(height: 16),
          _row(Strings.alcoholDays, widget.block['alcohol'] ?? '-'),
          const SizedBox(height: 16),
          _row(Strings.menstruationDays, widget.block['menstruation'] ?? '-'),
          _row(Strings.chocolateDays, widget.block['chocolate'] ?? '-'),
          _row(Strings.doctorVisits, widget.block['doctor'] ?? '-'),
          _row(Strings.eyePainDays, widget.block['eyePain'] ?? '-'),
          _row(Strings.vomitingDays, widget.block['vomit'] ?? '-'),
          _row(
            Strings.preventivePillDays,
            widget.block['preventivePill'] ?? '-',
          ),
          if (canExport) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _exporting ? null : _exportPdf,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.buttonColor,
                      ),
                    )
                  : const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.buttonColor,
                    ),
              label: Text(
                _exporting ? Strings.pdfExporting : Strings.exportPdf,
                style: const TextStyle(color: AppColors.buttonColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.buttonColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
