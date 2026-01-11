import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/firebase_field_name.dart';
import '../statistics_shared.dart';
import '../models/monthly_statistics_model.dart';

class MonthlyStatisticsStorage {
  const MonthlyStatisticsStorage();

  /// Fetches monthly statistics for the current user.
  Future<List<MonthlyStatisticsModel>> fetchMonthlyStatistics() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return [];

    final col = FirebaseFirestore.instance.collection('entries').doc(uid).collection('days');
    final q = await col.get();

    if (q.docs.isEmpty) return [];

    DateTime? minDate;
    DateTime? maxDate;
    final parsedDocs = <Map<String, dynamic>>[];

    for (final doc in q.docs) {
      final data = doc.data();
      final dateStr = (data[FirebaseFieldName.date] ?? '') as String;
      if (dateStr.length < 10) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(dateStr);
      } catch (_) {
        continue;
      }
      parsedDocs.add({'data': data, 'date': dt});
      if (minDate == null || dt.isBefore(minDate)) minDate = dt;
      if (maxDate == null || dt.isAfter(maxDate)) maxDate = dt;
    }

    if (minDate == null || maxDate == null) return [];

    final start = DateTime(minDate.year, minDate.month, 1);
    final end = DateTime(maxDate.year, maxDate.month, DateTime(maxDate.year, maxDate.month + 1, 0).day);

    final monthsCount = (end.year - start.year) * 12 + (end.month - start.month) + 1;

    final months = List.generate(monthsCount, (_) => {
          'headacheDays': 0,
          'pills': 0,
          'systal': 0,
          'run': 0,
          'strength': 0,
          'sex': 0,
          'alcohol': 0,
          'menstruation': 0,
          'rightSide': 0,
          'leftSide': 0,
          'overhead': 0,
        });

    for (final pd in parsedDocs) {
      final data = pd['data'] as Map<String, dynamic>;
      final dt = pd['date'] as DateTime;
      final idx = (dt.year - start.year) * 12 + (dt.month - start.month);
      if (idx < 0 || idx >= monthsCount) continue;

      final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});
      final medication = Map<String, dynamic>.from(data[FirebaseFieldName.medication] ?? {});
      final m = months[idx];

      for (final key in icons.keys) {
        final k = key.toString().toLowerCase();
        if (k.contains(FirebaseFieldName.peavaluRight)) {
          m['rightSide'] = toInt(m['rightSide']) + 1;
          m['headacheDays'] = toInt(m['headacheDays']) + 1;
        }
        if (k.contains(FirebaseFieldName.peavaluLeft)) {
          m['leftSide'] = toInt(m['leftSide']) + 1;
          m['headacheDays'] = toInt(m['headacheDays']) + 1;
        }
        if (k.contains(FirebaseFieldName.peavaluFull)) {
          m['overhead'] = toInt(m['overhead']) + 1;
          m['headacheDays'] = toInt(m['headacheDays']) + 1;
        }
      }

      m['pills'] = toInt(m['pills']) + toInt(medication[FirebaseFieldName.pill]);
      if (icons[FirebaseFieldName.systal] == true) m['systal'] = toInt(m['systal']) + 1;
      if (icons[FirebaseFieldName.run] == true) m['run'] = toInt(m['run']) + 1;
      if (icons[FirebaseFieldName.gym] == true) m['strength'] = toInt(m['strength']) + 1;
      if (icons[FirebaseFieldName.sex] == true || icons['sex'] == true) m['sex'] = toInt(m['sex']) + 1;
      if (icons[FirebaseFieldName.wine] == true) m['alcohol'] = toInt(m['alcohol']) + 1;
      if (icons[FirebaseFieldName.blood] == true) m['menstruation'] = toInt(m['menstruation']) + 1;
    }

    final result = <MonthlyStatisticsModel>[];
    for (var i = 0; i < monthsCount; i++) {
      final m = months[i];
      final monthDate = DateTime(start.year, start.month + i);
      result.add(MonthlyStatisticsModel(
        title: estMonth(monthDate),
        year: monthDate.year,
        month: monthDate.month,
        headacheDays: toInt(m['headacheDays']) > 0 ? toInt(m['headacheDays']).toString() : '-',
        rightSide: toInt(m['rightSide']) > 0 ? toInt(m['rightSide']).toString() : '-',
        leftSide: toInt(m['leftSide']) > 0 ? toInt(m['leftSide']).toString() : '-',
        overhead: toInt(m['overhead']) > 0 ? toInt(m['overhead']).toString() : '-',
        pills: toInt(m['pills']) > 0 ? toInt(m['pills']).toString() : '-',
        systal: toInt(m['systal']) > 0 ? toInt(m['systal']).toString() : '-',
        run: toInt(m['run']) > 0 ? toInt(m['run']).toString() : '-',
        strength: toInt(m['strength']) > 0 ? toInt(m['strength']).toString() : '-',
        sex: toInt(m['sex']) > 0 ? toInt(m['sex']).toString() : '-',
        alcohol: toInt(m['alcohol']) > 0 ? toInt(m['alcohol']).toString() : '-',
        menstruation: toInt(m['menstruation']) > 0 ? toInt(m['menstruation']).toString() : '-',
      ));
    }

    return result;
  }
}

