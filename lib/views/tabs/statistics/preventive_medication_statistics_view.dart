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
    final grouped = <String, List<_MedicationDay>>{};
    for (final entry in entries) {
      final isPill = entry.icons[FirebaseFieldName.preventivePill] == true;
      final isInjection = entry.icons[FirebaseFieldName.systal] == true;
      if (!isPill && !isInjection) {
        continue;
      }
      final name = (entry.medication[
                  FirebaseFieldName.preventiveMedicationName] ??
              entry.medication[FirebaseFieldName.preventivePillName])
          ?.toString()
          .trim();
      final mg = (entry.medication[FirebaseFieldName.preventiveMedicationMg] ??
              entry.medication[FirebaseFieldName.preventivePillGrams])
          ?.toString()
          .trim();
      if (name == null || name.isEmpty || mg == null || mg.isEmpty) {
        continue;
      }
      final type = isPill ? Strings.preventivePill : Strings.injection;
      final key = '$type|$name|$mg';
      final end = entry.medication[FirebaseFieldName.preventiveMedicationEnd];
      grouped.putIfAbsent(key, () => []).add(
        _MedicationDay(
          DateTime.parse(entry.date),
          end == null ? null : DateTime.tryParse(end.toString()),
        ),
      );
    }

    final result = <_Course>[];
    for (final item in grouped.entries) {
      final days = item.value..sort((a, b) => a.date.compareTo(b.date));
      var start = days.first.date;
      var previous = days.first.date;
      var taken = 1;
      DateTime? explicitEnd = days.first.end;
      for (var i = 1; i < days.length; i++) {
        final gap = days[i].date.difference(previous).inDays;
        if (gap > 7) {
          result.add(_Course(item.key, start, explicitEnd ?? previous, taken));
          start = days[i].date;
          taken = 0;
          explicitEnd = null;
        }
        previous = days[i].date;
        if (days[i].end != null &&
            (explicitEnd == null || days[i].end!.isAfter(explicitEnd))) {
          explicitEnd = days[i].end;
        }
        taken++;
      }
      result.add(_Course(item.key, start, explicitEnd ?? previous, taken));
    }
    result.sort((a, b) => b.start.compareTo(a.start));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        title: Text(Strings.preventiveMedicationSummary),
        backgroundColor: AppColors.accentColor,
      ),
      body: FutureBuilder<List<DayEntryModel>>(
        future: DayEntryStorage().allEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${Strings.error}: ${snapshot.error}'));
          }
          final entries = snapshot.data ?? [];
          final courses = _courses(entries);
          final reminders = entries.where((entry) {
            final time = entry.reminder?[FirebaseFieldName.time];
            final enabled = entry.reminder?[FirebaseFieldName.enabled] == true;
            final date = time == null ? null : DateTime.tryParse(time.toString());
            return enabled && date != null && date.isAfter(DateTime.now());
          }).toList()..sort((a, b) {
            final aDate = DateTime.parse(a.reminder![FirebaseFieldName.time].toString());
            final bDate = DateTime.parse(b.reminder![FirebaseFieldName.time].toString());
            return aDate.compareTo(bDate);
          });
          if (courses.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(12),
              children: [_activeReminders(reminders)],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: courses.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _activeReminders(reminders);
              final course = courses[index - 1];
              final parts = course.key.split('|');
              return Card(
                color: AppColors.black,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${parts[0]}: ${parts[1]}',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${Strings.dose}: ${parts[2]} mg',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${_date(course.start)} - ${_date(course.end)}',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      Text(
                        '${Strings.takenDays}: ${course.taken}',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      Text(
                        '${Strings.duration}: ${_duration(course.end.difference(course.start).inDays + 1)}',
                        style: TextStyle(color: AppColors.textColor),
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

  Widget _activeReminders(List<DayEntryModel> entries) {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.activeReminders,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (entries.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  Strings.noActiveReminders,
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
            for (final entry in entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  entry.reminder?[FirebaseFieldName.preventiveMedicationName]
                          ?.toString() ??
                      entry.reminder?[FirebaseFieldName.reminderType]
                          ?.toString() ??
                      Strings.reminderFor,
                  style: TextStyle(color: AppColors.textColor),
                ),
                subtitle: Text(
                  '${_date(DateTime.parse(entry.reminder![FirebaseFieldName.time].toString()))} • ${entry.date}',
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Course {
  final String key;
  final DateTime start;
  final DateTime end;
  final int taken;

  _Course(this.key, this.start, this.end, this.taken);
}

class _MedicationDay {
  final DateTime date;
  final DateTime? end;

  _MedicationDay(this.date, this.end);
}
