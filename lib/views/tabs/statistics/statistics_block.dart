import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class StatisticsBlock extends StatelessWidget {
  final Map<String, String> block;
  const StatisticsBlock({super.key, required this.block, bool focused = false});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(label, style: const TextStyle(color: AppColors.buttonColor, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(color: AppColors.textColor, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              block['title'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textColor, fontSize: 36, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),

          _row(Strings.headacheDays, block['headacheDays'] ?? '-'),
          _row(Strings.rightSideHeadaches, block['rightSide'] ?? '-'),
          _row(Strings.leftSideHeadaches, block['leftSide'] ?? '-'),
          _row(Strings.overheadHeadaches, block['overhead'] ?? '-'),
          const SizedBox(height: 16),

          _row(Strings.pillsTaken, block['pills'] ?? '-'),
          _row(Strings.injectionsMade, block['systal'] ?? '-'),
          const SizedBox(height: 16),

          _row(Strings.cardioDays, block['run'] ?? '-'),
          _row(Strings.strengthDays, block['strength'] ?? '-'),
          _row(Strings.intercourseDays, block['sex'] ?? '-'),
          const SizedBox(height: 16),

          _row(Strings.alcoholDays, block['alcohol'] ?? '-'),
          const SizedBox(height: 16),
          _row(Strings.menstruationDays, block['menstruation'] ?? '-'),
        ],
      ),
    );
  }
}

