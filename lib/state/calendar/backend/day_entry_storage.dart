import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/firebase_field_name.dart';
import '../models/day_entry_model.dart';
import '../../../services/firestore/day_entry_firestore.dart';
import '../../../services/notifications/notification_service.dart';
import '../../auth/backend/local_storage.dart';
import 'local_day_entry_storage.dart';

class DayEntryStorage {
  const DayEntryStorage();

  String? _uid() => FirebaseAuth.instance.currentUser?.uid;
  LocalDayEntryStorage get _localStorage => const LocalDayEntryStorage();

  Map<String, dynamic> _toPayload(DayEntryModel entry) => {
    FirebaseFieldName.date: entry.date,
    FirebaseFieldName.icons: entry.icons,
    FirebaseFieldName.medication: entry.medication,
    FirebaseFieldName.notes: entry.notes,
    if (entry.reminder != null) FirebaseFieldName.reminder: entry.reminder,
  };

  DayEntryModel? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists || doc.data() == null) return null;
    return DayEntryModel.fromJson(Map<String, dynamic>.from(doc.data()!));
  }

  Future<DayEntryModel> _getOrCreate(String uid, DateTime date) async {
    final dateIso = DayEntryFirestore.formatDate(date);
    final docRef = DayEntryFirestore.daysCollection(uid).doc(dateIso);
    final snap = await docRef.get(const GetOptions(source: Source.cache));
    if (snap.exists && snap.data() != null) {
      return DayEntryModel.fromJson(Map<String, dynamic>.from(snap.data()!));
    }

    final serverSnap = await docRef.get();
    if (serverSnap.exists && serverSnap.data() != null) {
      return DayEntryModel.fromJson(
        Map<String, dynamic>.from(serverSnap.data()!),
      );
    }

    return DayEntryModel(date: dateIso, icons: {}, medication: {}, notes: '');
  }

  Future<void> _saveEntry(String uid, DayEntryModel entry) async {
    final dateIso = DayEntryFirestore.formatDate(DateTime.parse(entry.date));
    final docRef = DayEntryFirestore.daysCollection(uid).doc(dateIso);
    await docRef.set(_toPayload(entry));
  }

  Stream<Map<DateTime, DayEntryModel>> monthEntries(
    DateTime start,
    DateTime end,
  ) {
    if (LocalStorage.isGuest) return _localStorage.monthEntries(start, end);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return const Stream.empty();

    final startIso = DayEntryFirestore.formatDate(start);
    final endIso = DayEntryFirestore.formatDate(end);

    return DayEntryFirestore.daysCollection(uid)
        .where(FirebaseFieldName.date, isGreaterThanOrEqualTo: startIso)
        .where(FirebaseFieldName.date, isLessThanOrEqualTo: endIso)
        .snapshots()
        .map((snapshot) {
          final map = <DateTime, DayEntryModel>{};
          for (final doc in snapshot.docs) {
            final entry = _fromDoc(doc);
            if (entry == null) continue;
            final dt = DateTime.parse(entry.date);
            map[DateTime(dt.year, dt.month, dt.day)] = entry;
          }
          return map;
        });
  }

  Stream<DayEntryModel?> dayEntryStream(DateTime date) {
    if (LocalStorage.isGuest) return _localStorage.dayEntryStream(date);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return const Stream.empty();

    final dateIso = DayEntryFirestore.formatDate(date);
    return DayEntryFirestore.daysCollection(
      uid,
    ).doc(dateIso).snapshots().map(_fromDoc);
  }

  Future<List<DayEntryModel>> allEntries() async {
    if (LocalStorage.isGuest) {
      return LocalStorage.entries.map(DayEntryModel.fromJson).toList();
    }
    final uid = _uid() ?? '';
    if (uid.isEmpty) return [];
    final snapshot = await DayEntryFirestore.daysCollection(uid).get();
    return snapshot.docs.map(_fromDoc).whereType<DayEntryModel>().toList();
  }

  /// Toggles an icon for [date]. Returns true if the icon was added, false if removed.
  Future<bool> toggleIcon(DateTime date, String key) async {
    if (LocalStorage.isGuest) return _localStorage.toggleIcon(date, key);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return false;

    final entry = await _getOrCreate(uid, date);
    final icons = Map<String, dynamic>.from(entry.icons);

    if (icons.containsKey(key) && icons[key] == true) {
      icons.remove(key);
      var reminder = entry.reminder;

      if ((key == FirebaseFieldName.systal ||
              key == FirebaseFieldName.preventivePill) &&
          reminder != null) {
        try {
          final notificationId = reminder[FirebaseFieldName.notificationId];
          if (notificationId != null) {
            await NotificationService().cancelNotificationById(
              (notificationId as num).toInt(),
            );
          }
        } catch (_) {}
        reminder = null;
      }

      final updated = entry.copyWith(icons: icons, reminder: reminder);
      await _saveEntry(uid, updated);
      return false;
    }

    icons[key] = true;
    final updated = entry.copyWith(icons: icons);
    await _saveEntry(uid, updated);
    return true;
  }

  Future<void> changePillCount(DateTime date, int delta) async {
    if (LocalStorage.isGuest) return _localStorage.changePillCount(date, delta);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return;

    final entry = await _getOrCreate(uid, date);
    final meds = Map<String, dynamic>.from(entry.medication);
    final current = (meds[FirebaseFieldName.pill] ?? 0) as int;
    final next = (current + delta).clamp(0, 9999);
    meds[FirebaseFieldName.pill] = next;

    final updated = entry.copyWith(medication: meds);
    await _saveEntry(uid, updated);
  }

  Future<void> editNotes(DateTime date, String notes) async {
    if (LocalStorage.isGuest) return _localStorage.editNotes(date, notes);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return;

    final entry = await _getOrCreate(uid, date);
    final updated = entry.copyWith(notes: notes);
    await _saveEntry(uid, updated);
  }

  /// Adds systal for a future date. If the icon already exists it will be removed instead.
  /// Returns:
  /// 0 = added or removed for today/past date
  /// 1 = added and scheduled
  /// 2 = added but scheduling failed or permission denied
  /// 3 = removed
  Future<int> addInjections(DateTime date) async {
    if (LocalStorage.isGuest) return _localStorage.addInjections(date);
    final uid = _uid() ?? '';
    if (uid.isEmpty) return 0;

    final today = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    if (!selected.isAfter(DateTime(today.year, today.month, today.day))) {
      await toggleIcon(date, FirebaseFieldName.systal);
      return 0;
    }

    final entry = await _getOrCreate(uid, date);
    final icons = Map<String, dynamic>.from(entry.icons);

    if (icons.containsKey(FirebaseFieldName.systal) &&
        icons[FirebaseFieldName.systal] == true) {
      icons.remove(FirebaseFieldName.systal);
      try {
        final reminder = entry.reminder;
        if (reminder != null &&
            reminder.containsKey(FirebaseFieldName.notificationId)) {
          final id = (reminder[FirebaseFieldName.notificationId] as num)
              .toInt();
          await NotificationService().cancelNotificationById(id);
        }
      } catch (_) {}

      final updated = entry.copyWith(icons: icons, reminder: null);
      await _saveEntry(uid, updated);
      return 3;
    }

    icons[FirebaseFieldName.systal] = true;

    final scheduledDate = DateTime(date.year, date.month, date.day, 12, 0);
    final scheduledId = await NotificationService()
        .scheduleInjectionNotification(scheduledDate);

    final reminderTime = scheduledDate.toIso8601String();
    final reminder = {
      FirebaseFieldName.enabled: true,
      FirebaseFieldName.time: reminderTime,
      if (scheduledId != null) FirebaseFieldName.notificationId: scheduledId,
    };

    final updated = entry.copyWith(icons: icons, reminder: reminder);
    await _saveEntry(uid, updated);
    return scheduledId != null ? 1 : 2;
  }

  Future<int> addFutureReminder({
    required DateTime date,
    required String iconKey,
    required DateTime reminderDate,
    required String title,
    required String body,
    Map<String, dynamic> details = const {},
  }) async {
    if (LocalStorage.isGuest) {
      return _localStorage.addFutureReminder(
        date: date,
        iconKey: iconKey,
        reminderDate: reminderDate,
        title: title,
        body: body,
        details: details,
      );
    }
    final uid = _uid() ?? '';
    if (uid.isEmpty) return 0;
    final entry = await _getOrCreate(uid, date);
    final icons = Map<String, dynamic>.from(entry.icons);
    if (icons[iconKey] == true) {
      icons.remove(iconKey);
      final id = entry.reminder?[FirebaseFieldName.notificationId];
      if (id is num) {
        await NotificationService().cancelNotificationById(id.toInt());
      }
      await _saveEntry(uid, entry.copyWith(icons: icons, reminder: null));
      return 3;
    }
    icons[iconKey] = true;
    final medication = Map<String, dynamic>.from(entry.medication);
    if (iconKey == FirebaseFieldName.preventivePill) {
      medication.addAll({
        FirebaseFieldName.preventivePillName:
            details[FirebaseFieldName.preventivePillName],
        FirebaseFieldName.preventivePillGrams:
            details[FirebaseFieldName.preventivePillGrams],
      });
    }
    final id =
        NotificationService().notificationIdForDate(reminderDate) +
        (iconKey == FirebaseFieldName.doctor ? 10000000 : 20000000);
    final scheduledId = await NotificationService().scheduleNotification(
      reminderDate,
      title,
      body,
      id,
    );
    final reminder = {
      FirebaseFieldName.enabled: true,
      FirebaseFieldName.reminderType: iconKey,
      FirebaseFieldName.time: reminderDate.toIso8601String(),
      ...details,
      if (scheduledId != null) FirebaseFieldName.notificationId: scheduledId,
    };
    await _saveEntry(
      uid,
      entry.copyWith(icons: icons, medication: medication, reminder: reminder),
    );
    return scheduledId == null ? 2 : 1;
  }

  Future<int> addPreventiveMedication({
    required DateTime date,
    required String iconKey,
    required String name,
    required double milligrams,
    DateTime? endDate,
    DateTime? reminderDate,
    required String title,
    required String body,
  }) async {
    if (LocalStorage.isGuest) {
      return _localStorage.addPreventiveMedication(
        date: date,
        iconKey: iconKey,
        name: name,
        milligrams: milligrams,
        endDate: endDate,
        reminderDate: reminderDate,
        title: title,
        body: body,
      );
    }
    final uid = _uid() ?? '';
    if (uid.isEmpty) return 0;

    final entry = await _getOrCreate(uid, date);
    final icons = Map<String, dynamic>.from(entry.icons);
    if (icons[iconKey] == true) {
      icons.remove(iconKey);
      final id = entry.reminder?[FirebaseFieldName.notificationId];
      if (id is num) {
        await NotificationService().cancelNotificationById(id.toInt());
      }
      await _saveEntry(uid, entry.copyWith(icons: icons, reminder: null));
      return 3;
    }

    final selected = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final isFuture = selected.isAfter(DateTime(today.year, today.month, today.day));
    final medication = Map<String, dynamic>.from(entry.medication)
      ..addAll({
        FirebaseFieldName.preventiveMedicationName: name,
        FirebaseFieldName.preventiveMedicationMg: milligrams,
        FirebaseFieldName.preventiveMedicationStart: entry.date,
        if (endDate != null)
          FirebaseFieldName.preventiveMedicationEnd:
              endDate.toIso8601String().substring(0, 10),
        if (iconKey == FirebaseFieldName.preventivePill) ...{
          FirebaseFieldName.preventivePillName: name,
          FirebaseFieldName.preventivePillGrams: milligrams,
        },
      });

    int? scheduledId;
    if (isFuture && reminderDate != null) {
      scheduledId = await NotificationService().scheduleNotification(
        reminderDate,
        title,
        body,
        NotificationService().notificationIdForDate(reminderDate) +
            (iconKey == FirebaseFieldName.systal ? 30000000 : 20000000),
      );
    }

    icons[iconKey] = true;
    final reminder = isFuture && reminderDate != null
        ? {
            FirebaseFieldName.enabled: true,
            FirebaseFieldName.reminderType: iconKey,
            FirebaseFieldName.time: reminderDate.toIso8601String(),
            FirebaseFieldName.preventiveMedicationName: name,
            FirebaseFieldName.preventiveMedicationMg: milligrams,
            if (scheduledId != null)
              FirebaseFieldName.notificationId: scheduledId,
          }
        : null;
    await _saveEntry(
      uid,
      entry.copyWith(
        icons: icons,
        medication: medication,
        reminder: reminder,
      ),
    );
    if (!isFuture) return 0;
    return scheduledId == null ? 2 : 1;
  }
}
