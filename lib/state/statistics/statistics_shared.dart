import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../views/constants/strings.dart';
import '../constants/firebase_field_name.dart';

int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String estMonth(DateTime date) {
  final monthsEst = [
    Strings.january,
    Strings.february,
    Strings.march,
    Strings.april,
    Strings.may,
    Strings.june,
    Strings.july,
    Strings.august,
    Strings.september,
    Strings.october,
    Strings.november,
    Strings.december,
  ];
  final name = monthsEst[date.month - 1];
  final cap = name.isNotEmpty ? (name[0].toUpperCase() + name.substring(1)) : name;
  return '$cap ${date.year}';
}

Future<Map<String, String>> aggregateForPeriod(DateTime start, DateTime end) async {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (uid.isEmpty) return {};
  final col = FirebaseFirestore.instance.collection('users').doc(uid).collection('days');
  final startIso = DateTime(start.year, start.month, start.day).toIso8601String().substring(0, 10);
  final endIso = DateTime(end.year, end.month, end.day).toIso8601String().substring(0, 10);

  final q = await col.where('date', isGreaterThanOrEqualTo: startIso).where('date', isLessThanOrEqualTo: endIso).get();

  int headacheDays = 0;
  int pills = 0;
  int systal = 0;
  int run = 0;
  int strength = 0;
  int sex = 0;
  int alcohol = 0;
  int menstruation = 0;
  int rightSide = 0;
  int leftSide = 0;
  int overhead = 0;

  for (final doc in q.docs) {
    final data = doc.data();
    final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});
    final medication = Map<String, dynamic>.from(data[FirebaseFieldName.medication] ?? {});

    pills += toInt(medication[FirebaseFieldName.pill]);

    if (icons[FirebaseFieldName.systal] == true) systal++;
    if (icons[FirebaseFieldName.run] == true) run++;
    if (icons[FirebaseFieldName.gym] == true) strength++;
    if (icons[FirebaseFieldName.sex] == true) sex++;
    if (icons[FirebaseFieldName.wine] == true) alcohol++;
    if (icons[FirebaseFieldName.blood] == true) menstruation++;

    for (final key in icons.keys) {
      final k = key.toString().toLowerCase();
      if (k.contains(FirebaseFieldName.peavaluRight)) {
        rightSide++;
        headacheDays++;
      }
      if (k.contains(FirebaseFieldName.peavaluLeft)) {
        leftSide++;
        headacheDays++;
      }
      if (k.contains(FirebaseFieldName.peavaluFull)) {
        overhead++;
        headacheDays++;
      }
    }
  }

  return {
    'title': DateTime(start.year, start.month, start.day).toIso8601String().substring(0, 10),
    'headacheDays': headacheDays > 0 ? headacheDays.toString() : '-',
    'rightSide': rightSide > 0 ? rightSide.toString() : '-',
    'leftSide': leftSide > 0 ? leftSide.toString() : '-',
    'overhead': overhead > 0 ? overhead.toString() : '-',
    'pills': pills > 0 ? pills.toString() : '-',
    'systal': systal > 0 ? systal.toString() : '-',
    'run': run > 0 ? run.toString() : '-',
    'strength': strength > 0 ? strength.toString() : '-',
    'sex': sex > 0 ? sex.toString() : '-',
    'alcohol': alcohol > 0 ? alcohol.toString() : '-',
    'menstruation': menstruation > 0 ? menstruation.toString() : '-',
  };
}

