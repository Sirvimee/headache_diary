import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/firebase_field_name.dart';
import '../models/day_entry_model.dart';

class DayEntryStorage {
  const DayEntryStorage();

  String _fmt(DateTime d) => d.toIso8601String().substring(0, 10);

  Stream<Map<DateTime, DayEntryModel>> monthEntries(DateTime start, DateTime end) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('entries')
        .doc(uid)
        .collection('days')
        .where(FirebaseFieldName.date, isGreaterThanOrEqualTo: _fmt(start))
        .where(FirebaseFieldName.date, isLessThanOrEqualTo: _fmt(end))
        .snapshots()
        .map((snap) {
      final map = <DateTime, DayEntryModel>{};
      for (var d in snap.docs) {
        final data = d.data();
        final dt = DateTime.parse(data[FirebaseFieldName.date]);
        map[DateTime(dt.year, dt.month, dt.day)] = DayEntryModel.fromJson(Map<String, dynamic>.from(data));
      }
      return map;
    });
  }

  Stream<DayEntryModel?> dayEntryStream(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return const Stream.empty();

    final dateIso = _fmt(date);
    final docRef = FirebaseFirestore.instance.collection('entries').doc(uid).collection('days').doc(dateIso);
    return docRef.snapshots().map((snap) => snap.exists ? DayEntryModel.fromJson(Map<String, dynamic>.from(snap.data()!)) : null);
  }

  Future<DocumentReference> _getOrCreateDayDocRef(DateTime date) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final dateIso = _fmt(date);
    final col = FirebaseFirestore.instance.collection('entries').doc(uid).collection('days');

    final docRef = col.doc(dateIso);
    final docSnap = await docRef.get();
    if (docSnap.exists) return docRef;

    // Check for legacy doc stored with auto-id but with date field
    final q = await col.where(FirebaseFieldName.date, isEqualTo: dateIso).limit(1).get();
    if (q.docs.isNotEmpty) {
      final old = q.docs.first;
      final data = old.data();
      await docRef.set(data);
      // delete old doc to keep single source of truth
      try {
        await old.reference.delete();
      } catch (_) {}
      return docRef;
    }

    final payload = {
      FirebaseFieldName.date: dateIso,
      FirebaseFieldName.medication: {},
      FirebaseFieldName.icons: {},
      FirebaseFieldName.notes: '',
    };

    await docRef.set(payload);
    return docRef;
  }

  Future<void> toggleIcon(DateTime date, String key) async {
    final ref = await _getOrCreateDayDocRef(date);
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});

    if (icons.containsKey(key) && icons[key] == true) {
      icons.remove(key);
      await ref.update({FirebaseFieldName.icons: icons});

      if (key == FirebaseFieldName.systal) {
        try {
          await ref.update({FirebaseFieldName.reminder: FieldValue.delete()});
        } catch (_) {}
      }
    } else {
      icons[key] = true;
      await ref.update({FirebaseFieldName.icons: icons});
    }
  }

  Future<void> changePillCount(DateTime date, int delta) async {
    final ref = await _getOrCreateDayDocRef(date);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>? ?? {};
      final meds = Map<String, dynamic>.from(data[FirebaseFieldName.medication] ?? {});
      final current = (meds[FirebaseFieldName.pill] ?? 0) as int;
      final next = (current + delta).clamp(0, 9999);
      meds[FirebaseFieldName.pill] = next;
      tx.update(ref, {FirebaseFieldName.medication: meds});
    });
  }

  Future<void> editNotes(DateTime date, String notes) async {
    final ref = await _getOrCreateDayDocRef(date);
    await ref.update({FirebaseFieldName.notes: notes});
  }

  Future<void> addSystalForFuture(DateTime date) async {
    final today = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    if (!selected.isAfter(DateTime(today.year, today.month, today.day))) {
      await toggleIcon(date, FirebaseFieldName.systal);
      return;
    }

    final ref = await _getOrCreateDayDocRef(date);
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});
    icons[FirebaseFieldName.systal] = true;

    final reminderTime = DateTime(date.year, date.month, date.day, 9, 0).toIso8601String();
    final reminder = {FirebaseFieldName.enabled: true, FirebaseFieldName.time: reminderTime};

    await ref.update({FirebaseFieldName.icons: icons, FirebaseFieldName.reminder: reminder});
  }
}
