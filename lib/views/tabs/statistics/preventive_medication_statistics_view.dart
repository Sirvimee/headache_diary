import 'package:flutter/material.dart';

import '../../../state/calendar/backend/day_entry_storage.dart';
import '../../../state/calendar/models/day_entry_model.dart';
import '../../../state/constants/firebase_field_name.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class PreventiveMedicationStatisticsView extends StatelessWidget {
  const PreventiveMedicationStatisticsView({super.key});

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  String _duration(int days) {
    if (days < 14) return '$days päeva';
    final weeks = days ~/ 7;
    final months = weeks ~/ 4;
    final remainingWeeks = weeks % 4;
    if (months == 0) return '$weeks nädalat';
    if (remainingWeeks == 0) return '$months kuud';
    return '$months kuud ja $remainingWeeks nädalat';
  }

  List<_Course> _courses(List<DayEntryModel> entries) {
    final grouped = <String, List<DateTime>>{};
    for (final entry in entries) {
      if (entry.icons[FirebaseFieldName.preventivePill] != true) {
        continue;
      }
      final name = entry.medication[FirebaseFieldName.preventivePillName]
          ?.toString()
          .trim();
      final grams = entry.medication[FirebaseFieldName.preventivePillGrams]
          ?.toString()
          .trim();
      if (name == null || name.isEmpty || grams == null || grams.isEmpty) {
        continue;
      }
      final key = '$name|$grams';
      grouped.putIfAbsent(key, () => []).add(DateTime.parse(entry.date));
    }

    final result = <_Course>[];
    for (final item in grouped.entries) {
      final dates = item.value..sort();
      var start = dates.first;
      var previous = dates.first;
      var taken = 1;
      for (var i = 1; i < dates.length; i++) {
        final gap = dates[i].difference(previous).inDays;
        if (gap > 7) {
          result.add(_Course(item.key, start, previous, taken));
          start = dates[i];
          taken = 0;
        }
        previous = dates[i];
        taken++;
      }
      result.add(_Course(item.key, start, previous, taken));
    }
    result.sort((a, b) => b.start.compareTo(a.start));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        title: const Text(Strings.preventiveMedicationSummary),
        backgroundColor: AppColors.accentColor,
      ),
      body: FutureBuilder<List<DayEntryModel>>(
        future: const DayEntryStorage().allEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${Strings.error}: ${snapshot.error}'));
          }
          final courses = _courses(snapshot.data ?? []);
          if (courses.isEmpty) {
            return const Center(
              child: Text(Strings.noPreventiveMedicationData),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final parts = course.key.split('|');
              return Card(
                color: AppColors.black,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parts.first,
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Strings.dose}: ${parts.last} g',
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_date(course.start)} - ${_date(course.end)}',
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                      Text(
                        '${Strings.takenDays}: ${course.taken}',
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                      Text(
                        '${Strings.duration}: ${_duration(course.end.difference(course.start).inDays + 1)}',
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Course {
  final String key;
  final DateTime start;
  final DateTime end;
  final int taken;

  const _Course(this.key, this.start, this.end, this.taken);
}
