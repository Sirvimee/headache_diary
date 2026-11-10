import '../../../services/notifications/notification_service.dart';
import '../../auth/backend/local_storage.dart';
import '../../constants/firebase_field_name.dart';
import '../../../views/constants/strings.dart';
import '../models/day_entry_model.dart';

class LocalDayEntryStorage {
  const LocalDayEntryStorage();

  DayEntryModel _getOrCreate(DateTime date) {
    final dateIso = date.toIso8601String().substring(0, 10);
    final data = LocalStorage.getEntry(dateIso);
    return data == null
        ? DayEntryModel(date: dateIso, icons: {}, medication: {}, notes: '')
        : DayEntryModel.fromJson(data);
  }

  Future<void> _save(DayEntryModel entry) {
    return LocalStorage.saveEntry(entry.date, entry.toJson());
  }

  Future<int?> _scheduleReminder({
    required DateTime reminderDate,
    required String title,
    required String body,
    required String iconKey,
  }) {
    final id = NotificationService().notificationIdForDate(reminderDate) +
        (iconKey == FirebaseFieldName.doctor
            ? 10000000
            : iconKey == FirebaseFieldName.systal
            ? 30000000
            : 20000000);
    return NotificationService().scheduleNotification(
      reminderDate,
      title,
      body,
      id,
    );
  }

  Stream<Map<DateTime, DayEntryModel>> monthEntries(
    DateTime start,
    DateTime end,
  ) async* {
    final map = <DateTime, DayEntryModel>{};
    for (final data in LocalStorage.entries) {
      final entry = DayEntryModel.fromJson(data);
      final date = DateTime.parse(entry.date);
      if (!date.isBefore(start) && !date.isAfter(end)) {
        map[DateTime(date.year, date.month, date.day)] = entry;
      }
    }
    yield map;
  }

  Stream<DayEntryModel?> dayEntryStream(DateTime date) async* {
    final data = LocalStorage.getEntry(date.toIso8601String().substring(0, 10));
    yield data == null ? null : DayEntryModel.fromJson(data);
  }

  Future<bool> toggleIcon(DateTime date, String key) async {
    final entry = _getOrCreate(date);
    final icons = Map<String, dynamic>.from(entry.icons);
    Map<String, dynamic>? reminder = entry.reminder;
    if (icons[key] == true) {
      icons.remove(key);
      if ((key == FirebaseFieldName.systal ||
              key == FirebaseFieldName.preventivePill) &&
          reminder != null) {
        final id = reminder[FirebaseFieldName.notificationId];
        if (id is num) {
          await NotificationService().cancelNotificationById(id.toInt());
        }
        reminder = null;
      }
      await _save(entry.copyWith(icons: icons, reminder: reminder));
      return false;
    }
    icons[key] = true;
    await _save(entry.copyWith(icons: icons));
    return true;
  }

  Future<void> changePillCount(DateTime date, int delta) async {
    final entry = _getOrCreate(date);
    final medication = Map<String, dynamic>.from(entry.medication);
    final current = (medication[FirebaseFieldName.pill] ?? 0) as int;
    medication[FirebaseFieldName.pill] = (current + delta).clamp(0, 9999);
    await _save(entry.copyWith(medication: medication));
  }

  Future<void> editNotes(DateTime date, String notes) async {
    await _save(_getOrCreate(date).copyWith(notes: notes));
  }

  Future<void> deleteNotes(DateTime date) => editNotes(date, '');

  Future<int> addInjections(DateTime date) async {
    final selected = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    if (!selected.isAfter(DateTime(today.year, today.month, today.day))) {
      await toggleIcon(date, FirebaseFieldName.systal);
      return 0;
    }
    final entry = _getOrCreate(date);
    final icons = Map<String, dynamic>.from(entry.icons);
    if (icons[FirebaseFieldName.systal] == true) {
      icons.remove(FirebaseFieldName.systal);
      final id = entry.reminder?[FirebaseFieldName.notificationId];
      if (id is num) {
        await NotificationService().cancelNotificationById(id.toInt());
      }
      await _save(entry.copyWith(icons: icons, reminder: null));
      return 3;
    }
    icons[FirebaseFieldName.systal] = true;
    final scheduledDate = DateTime(date.year, date.month, date.day, 12);
    final id = await _scheduleReminder(
      reminderDate: scheduledDate,
      title: Strings.notificationTitle,
      body: Strings.notificationBody,
      iconKey: FirebaseFieldName.systal,
    );
    await _save(
      entry.copyWith(
        icons: icons,
        reminder: {
          FirebaseFieldName.enabled: true,
          FirebaseFieldName.time: scheduledDate.toIso8601String(),
          if (id != null) FirebaseFieldName.notificationId: id,
        },
      ),
    );
    return id == null ? 2 : 1;
  }

  Future<int> addFutureReminder({
    required DateTime date,
    required String iconKey,
    required DateTime reminderDate,
    required String title,
    required String body,
    Map<String, dynamic> details = const {},
  }) async {
    final entry = _getOrCreate(date);
    final icons = Map<String, dynamic>.from(entry.icons);
    if (icons[iconKey] == true) {
      icons.remove(iconKey);
      final id = entry.reminder?[FirebaseFieldName.notificationId];
      if (id is num) {
        await NotificationService().cancelNotificationById(id.toInt());
      }
      await _save(entry.copyWith(icons: icons, reminder: null));
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
    final scheduledId = await _scheduleReminder(
      reminderDate: reminderDate,
      title: title,
      body: body,
      iconKey: iconKey,
    );
    await _save(
      entry.copyWith(
        icons: icons,
        medication: medication,
        reminder: {
          FirebaseFieldName.enabled: true,
          FirebaseFieldName.reminderType: iconKey,
          FirebaseFieldName.time: reminderDate.toIso8601String(),
          ...details,
          if (scheduledId != null)
            FirebaseFieldName.notificationId: scheduledId,
        },
      ),
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
    final entry = _getOrCreate(date);
    final icons = Map<String, dynamic>.from(entry.icons);
    if (icons[iconKey] == true) {
      icons.remove(iconKey);
      final id = entry.reminder?[FirebaseFieldName.notificationId];
      if (id is num) {
        await NotificationService().cancelNotificationById(id.toInt());
      }
      await _save(entry.copyWith(icons: icons, reminder: null));
      return 3;
    }

    final selected = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final isFuture = selected.isAfter(
      DateTime(today.year, today.month, today.day),
    );
    final medication = Map<String, dynamic>.from(entry.medication)
      ..addAll({
        FirebaseFieldName.preventiveMedicationName: name,
        FirebaseFieldName.preventiveMedicationMg: milligrams,
        FirebaseFieldName.preventiveMedicationStart: entry.date,
        if (endDate != null)
          FirebaseFieldName.preventiveMedicationEnd: endDate
              .toIso8601String()
              .substring(0, 10),
        if (iconKey == FirebaseFieldName.preventivePill) ...{
          FirebaseFieldName.preventivePillName: name,
          FirebaseFieldName.preventivePillGrams: milligrams,
        },
      });

    int? scheduledId;
    if (isFuture && reminderDate != null) {
      scheduledId = await _scheduleReminder(
        reminderDate: reminderDate,
        title: title,
        body: body,
        iconKey: iconKey,
      );
    }
    icons[iconKey] = true;
    await _save(
      entry.copyWith(
        icons: icons,
        medication: medication,
        reminder: isFuture && reminderDate != null
            ? {
                FirebaseFieldName.enabled: true,
                FirebaseFieldName.reminderType: iconKey,
                FirebaseFieldName.time: reminderDate.toIso8601String(),
                FirebaseFieldName.preventiveMedicationName: name,
                FirebaseFieldName.preventiveMedicationMg: milligrams,
                if (scheduledId != null)
                  FirebaseFieldName.notificationId: scheduledId,
              }
            : null,
      ),
    );
    if (!isFuture) return 0;
    return scheduledId == null ? 2 : 1;
  }
}
