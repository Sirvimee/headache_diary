import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firestore/day_entry_firestore.dart';
import '../../constants/firebase_field_name.dart';
import '../statistics_shared.dart';
import '../models/monthly_statistics_model.dart';
import '../../auth/backend/local_storage.dart';

class MonthlyStatisticsStorage {
  const MonthlyStatisticsStorage();

  Future<List<MonthlyStatisticsModel>> fetchMonthlyStatistics() async {
    if (LocalStorage.isGuest) return _fromDocs(LocalStorage.entries.toList());
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return [];

    final col = DayEntryFirestore.daysCollection(uid);
    final cacheSnap = await col.get(const GetOptions(source: Source.cache));
    final snap = cacheSnap.docs.isNotEmpty ? cacheSnap : await col.get();
    if (snap.docs.isEmpty) return [];

    final parsedDocs = <Map<String, dynamic>>[];
    DateTime? minDate;
    DateTime? maxDate;

    for (final doc in snap.docs) {
      final data = doc.data();
      final dateStr = data[FirebaseFieldName.date] as String? ?? '';
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
    final end = DateTime(
      maxDate.year,
      maxDate.month,
      DateTime(maxDate.year, maxDate.month + 1, 0).day,
    );

    final monthsCount =
        (end.year - start.year) * 12 + (end.month - start.month) + 1;

    final months = List.generate(
      monthsCount,
      (_) => {
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
        'chocolate': 0,
        'doctor': 0,
        'eyePain': 0,
        'vomit': 0,
        'preventivePill': 0,
      },
    );

    for (final pd in parsedDocs) {
      final data = pd['data'] as Map<String, dynamic>;
      final dt = pd['date'] as DateTime;
      final idx = (dt.year - start.year) * 12 + (dt.month - start.month);
      if (idx < 0 || idx >= monthsCount) continue;

      final icons = Map<String, dynamic>.from(
        data[FirebaseFieldName.icons] ?? {},
      );
      final medication = Map<String, dynamic>.from(
        data[FirebaseFieldName.medication] ?? {},
      );
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

      m['pills'] =
          toInt(m['pills']) + toInt(medication[FirebaseFieldName.pill]);
      if (icons[FirebaseFieldName.systal] == true) {
        m['systal'] = toInt(m['systal']) + 1;
      }
      if (icons[FirebaseFieldName.run] == true) m['run'] = toInt(m['run']) + 1;
      if (icons[FirebaseFieldName.gym] == true) {
        m['strength'] = toInt(m['strength']) + 1;
      }
      if (icons[FirebaseFieldName.sex] == true || icons['sex'] == true) {
        m['sex'] = toInt(m['sex']) + 1;
      }
      if (icons[FirebaseFieldName.wine] == true) {
        m['alcohol'] = toInt(m['alcohol']) + 1;
      }
      if (icons[FirebaseFieldName.blood] == true) {
        m['menstruation'] = toInt(m['menstruation']) + 1;
      }
      if (icons[FirebaseFieldName.chocolate] == true) {
        m['chocolate'] = toInt(m['chocolate']) + 1;
      }
      if (icons[FirebaseFieldName.doctor] == true) {
        m['doctor'] = toInt(m['doctor']) + 1;
      }
      if (icons[FirebaseFieldName.eyePain] == true) {
        m['eyePain'] = toInt(m['eyePain']) + 1;
      }
      if (icons[FirebaseFieldName.vomit] == true) {
        m['vomit'] = toInt(m['vomit']) + 1;
      }
      if (icons[FirebaseFieldName.preventivePill] == true) {
        m['preventivePill'] = toInt(m['preventivePill']) + 1;
      }
    }

    final result = <MonthlyStatisticsModel>[];
    for (var i = 0; i < monthsCount; i++) {
      final m = months[i];
      final monthDate = DateTime(start.year, start.month + i);
      result.add(
        MonthlyStatisticsModel(
          title: estMonth(monthDate),
          year: monthDate.year,
          month: monthDate.month,
          headacheDays: toInt(m['headacheDays']) > 0
              ? toInt(m['headacheDays']).toString()
              : '-',
          rightSide: toInt(m['rightSide']) > 0
              ? toInt(m['rightSide']).toString()
              : '-',
          leftSide: toInt(m['leftSide']) > 0
              ? toInt(m['leftSide']).toString()
              : '-',
          overhead: toInt(m['overhead']) > 0
              ? toInt(m['overhead']).toString()
              : '-',
          pills: toInt(m['pills']) > 0 ? toInt(m['pills']).toString() : '-',
          systal: toInt(m['systal']) > 0 ? toInt(m['systal']).toString() : '-',
          run: toInt(m['run']) > 0 ? toInt(m['run']).toString() : '-',
          strength: toInt(m['strength']) > 0
              ? toInt(m['strength']).toString()
              : '-',
          sex: toInt(m['sex']) > 0 ? toInt(m['sex']).toString() : '-',
          alcohol: toInt(m['alcohol']) > 0
              ? toInt(m['alcohol']).toString()
              : '-',
          menstruation: toInt(m['menstruation']) > 0
              ? toInt(m['menstruation']).toString()
              : '-',
          chocolate: toInt(m['chocolate']) > 0
              ? toInt(m['chocolate']).toString()
              : '-',
          doctor: toInt(m['doctor']) > 0 ? toInt(m['doctor']).toString() : '-',
          eyePain: toInt(m['eyePain']) > 0
              ? toInt(m['eyePain']).toString()
              : '-',
          vomit: toInt(m['vomit']) > 0 ? toInt(m['vomit']).toString() : '-',
          preventivePill: toInt(m['preventivePill']) > 0
              ? toInt(m['preventivePill']).toString()
              : '-',
        ),
      );
    }

    return result;
  }

  List<MonthlyStatisticsModel> _fromDocs(List<Map<String, dynamic>> docs) {
    if (docs.isEmpty) return [];
    DateTime? minDate;
    DateTime? maxDate;
    final parsedDocs = <Map<String, dynamic>>[];
    for (final data in docs) {
      final dateStr = data[FirebaseFieldName.date] as String? ?? '';
      if (dateStr.length < 10) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      parsedDocs.add({'data': data, 'date': date});
      if (minDate == null || date.isBefore(minDate)) minDate = date;
      if (maxDate == null || date.isAfter(maxDate)) maxDate = date;
    }
    if (minDate == null || maxDate == null) return [];
    final start = DateTime(minDate.year, minDate.month, 1);
    final end = DateTime(maxDate.year, maxDate.month + 1, 0);
    final monthsCount =
        (end.year - start.year) * 12 + end.month - start.month + 1;
    final months = List.generate(
      monthsCount,
      (_) => <String, int>{
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
        'chocolate': 0,
        'doctor': 0,
        'eyePain': 0,
        'vomit': 0,
        'preventivePill': 0,
      },
    );
    for (final pd in parsedDocs) {
      final data = pd['data'] as Map<String, dynamic>;
      final date = pd['date'] as DateTime;
      final index = (date.year - start.year) * 12 + date.month - start.month;
      final icons = Map<String, dynamic>.from(
        data[FirebaseFieldName.icons] ?? {},
      );
      final medication = Map<String, dynamic>.from(
        data[FirebaseFieldName.medication] ?? {},
      );
      final month = months[index];
      for (final key in icons.keys) {
        final value = key.toString().toLowerCase();
        if (value.contains(FirebaseFieldName.peavaluRight)) {
          month['rightSide'] = month['rightSide']! + 1;
          month['headacheDays'] = month['headacheDays']! + 1;
        }
        if (value.contains(FirebaseFieldName.peavaluLeft)) {
          month['leftSide'] = month['leftSide']! + 1;
          month['headacheDays'] = month['headacheDays']! + 1;
        }
        if (value.contains(FirebaseFieldName.peavaluFull)) {
          month['overhead'] = month['overhead']! + 1;
          month['headacheDays'] = month['headacheDays']! + 1;
        }
      }
      month['pills'] =
          month['pills']! +
          ((medication[FirebaseFieldName.pill] as num?)?.toInt() ?? 0);
      if (icons[FirebaseFieldName.systal] == true) {
        month['systal'] = month['systal']! + 1;
      }
      if (icons[FirebaseFieldName.run] == true) {
        month['run'] = month['run']! + 1;
      }
      if (icons[FirebaseFieldName.gym] == true) {
        month['strength'] = month['strength']! + 1;
      }
      if (icons[FirebaseFieldName.sex] == true) {
        month['sex'] = month['sex']! + 1;
      }
      if (icons[FirebaseFieldName.wine] == true) {
        month['alcohol'] = month['alcohol']! + 1;
      }
      if (icons[FirebaseFieldName.blood] == true) {
        month['menstruation'] = month['menstruation']! + 1;
      }
      if (icons[FirebaseFieldName.chocolate] == true) {
        month['chocolate'] = month['chocolate']! + 1;
      }
      if (icons[FirebaseFieldName.doctor] == true) {
        month['doctor'] = month['doctor']! + 1;
      }
      if (icons[FirebaseFieldName.eyePain] == true) {
        month['eyePain'] = month['eyePain']! + 1;
      }
      if (icons[FirebaseFieldName.vomit] == true) {
        month['vomit'] = month['vomit']! + 1;
      }
      if (icons[FirebaseFieldName.preventivePill] == true) {
        month['preventivePill'] = month['preventivePill']! + 1;
      }
    }
    String value(int number) => number > 0 ? number.toString() : '-';
    return List.generate(monthsCount, (index) {
      final date = DateTime(start.year, start.month + index);
      final month = months[index];
      return MonthlyStatisticsModel(
        title: estMonth(date),
        year: date.year,
        month: date.month,
        headacheDays: value(month['headacheDays']!),
        rightSide: value(month['rightSide']!),
        leftSide: value(month['leftSide']!),
        overhead: value(month['overhead']!),
        pills: value(month['pills']!),
        systal: value(month['systal']!),
        run: value(month['run']!),
        strength: value(month['strength']!),
        sex: value(month['sex']!),
        alcohol: value(month['alcohol']!),
        menstruation: value(month['menstruation']!),
        chocolate: value(month['chocolate']!),
        doctor: value(month['doctor']!),
        eyePain: value(month['eyePain']!),
        vomit: value(month['vomit']!),
        preventivePill: value(month['preventivePill']!),
      );
    });
  }
}
