import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import 'statistics_block.dart';
import '../../../state/statistics/statistics_shared.dart';

class StatisticsPeriodView extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const StatisticsPeriodView({super.key, required this.start, required this.end});

  String _fmtPeriodHeader(DateTime s, DateTime e) {
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(s)} - ${df.format(e)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentColor,
      child: FutureBuilder<Map<String, String>>(
        future: aggregateForPeriod(start, end),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('${Strings.error}: ${snap.error}'));
          final block = snap.data ?? {};

          block['title'] = _fmtPeriodHeader(start, end);

          return ListView(
            padding: EdgeInsets.only(bottom: 24, top: 12),
            children: [
              StatisticsBlock(
                block: block,
                periodStart: start,
                periodEnd: end,
              ),
            ],
          );
        },
      ),
    );
  }
}

