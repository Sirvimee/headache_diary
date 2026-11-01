import '../../../services/notifications/notification_service.dart';
import '../../auth/backend/local_storage.dart';
import '../../constants/firebase_field_name.dart';
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
      if (key == FirebaseFieldName.systal && reminder != null) {
        final id = reminder[FirebaseFieldName.notificationId];
        if (id is num)
          await NotificationService().cancelNotificationById(id.toInt());
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
      if (id is num)
        await NotificationService().cancelNotificationById(id.toInt());
      await _save(entry.copyWith(icons: icons, reminder: null));
      return 3;
    }
    icons[FirebaseFieldName.systal] = true;
    final scheduledDate = DateTime(date.year, date.month, date.day, 12);
    int? id;
    try {
      id = await NotificationService().scheduleInjectionNotification(
        scheduledDate,
      );
    } catch (_) {}
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
}
