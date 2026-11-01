import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../services/firestore/day_entry_firestore.dart';
import '../../services/pdf/statistics_pdf_service.dart';
import '../../views/constants/strings.dart';
import '../constants/firebase_field_name.dart';
import '../auth/backend/local_storage.dart';

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
  final cap = name.isNotEmpty
      ? (name[0].toUpperCase() + name.substring(1))
      : name;
  return '$cap ${date.year}';
}

Map<String, String> _aggregateDocs(
  List<Map<String, dynamic>> docs,
  DateTime start,
) {
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

  for (final data in docs) {
    final icons = Map<String, dynamic>.from(
      data[FirebaseFieldName.icons] ?? {},
    );
    final medication = Map<String, dynamic>.from(
      data[FirebaseFieldName.medication] ?? {},
    );

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
    'title': DateTime(
      start.year,
      start.month,
      start.day,
    ).toIso8601String().substring(0, 10),
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

Future<List<Map<String, dynamic>>> _fetchDocsForRange(
  String uid,
  DateTime start,
  DateTime end,
) async {
  if (LocalStorage.isGuest) {
    final startIso = DayEntryFirestore.formatDate(start);
    final endIso = DayEntryFirestore.formatDate(end);
    return LocalStorage.entries.where((data) {
      final date = data[FirebaseFieldName.date] as String? ?? '';
      return date.compareTo(startIso) >= 0 && date.compareTo(endIso) <= 0;
    }).toList();
  }
  final startIso = DayEntryFirestore.formatDate(start);
  final endIso = DayEntryFirestore.formatDate(end);
  final query = DayEntryFirestore.daysCollection(uid)
      .where(FirebaseFieldName.date, isGreaterThanOrEqualTo: startIso)
      .where(FirebaseFieldName.date, isLessThanOrEqualTo: endIso);

  final cacheSnap = await query.get(const GetOptions(source: Source.cache));
  if (cacheSnap.docs.isNotEmpty) {
    return cacheSnap.docs
        .map((doc) => Map<String, dynamic>.from(doc.data()))
        .toList();
  }

  final snap = await query.get();
  return snap.docs.map((doc) => Map<String, dynamic>.from(doc.data())).toList();
}

Future<Map<String, String>> aggregateForPeriod(
  DateTime start,
  DateTime end,
) async {
  if (LocalStorage.isGuest) {
    return _aggregateDocs(await _fetchDocsForRange('', start, end), start);
  }
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (uid.isEmpty) return {};

  final docs = await _fetchDocsForRange(uid, start, end);
  return _aggregateDocs(docs, start);
}

DateTime monthStart(int year, int month) => DateTime(year, month, 1);

DateTime monthEnd(int year, int month) => DateTime(year, month + 1, 0);

Future<List<DayNoteEntry>> fetchNotesForPeriod(
  DateTime start,
  DateTime end,
) async {
  if (LocalStorage.isGuest) {
    final docs = await _fetchDocsForRange('', start, end);
    final dateFormat = DateFormat('dd.MM.yyyy');
    final notes = <DayNoteEntry>[];
    for (final data in docs) {
      final note = (data[FirebaseFieldName.notes] as String? ?? '').trim();
      final dateIso = data[FirebaseFieldName.date] as String? ?? '';
      if (note.isNotEmpty && dateIso.length >= 10) {
        notes.add(
          DayNoteEntry(
            date: dateFormat.format(DateTime.parse(dateIso)),
            note: note,
          ),
        );
      }
    }
    notes.sort((a, b) => a.date.compareTo(b.date));
    return notes;
  }
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (uid.isEmpty) return [];

  final docs = await _fetchDocsForRange(uid, start, end);
  final dateFormat = DateFormat('dd.MM.yyyy');
  final notes = <DayNoteEntry>[];

  for (final data in docs) {
    final note = (data[FirebaseFieldName.notes] as String? ?? '').trim();
    if (note.isEmpty) continue;
    final dateIso = data[FirebaseFieldName.date] as String? ?? '';
    if (dateIso.length < 10) continue;
    notes.add(
      DayNoteEntry(
        date: dateFormat.format(DateTime.parse(dateIso)),
        note: note,
      ),
    );
  }

  notes.sort((a, b) => a.date.compareTo(b.date));
  return notes;
}
