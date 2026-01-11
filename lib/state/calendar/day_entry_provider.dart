import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'backend/day_entry_storage.dart';
import 'models/day_entry_model.dart';

part 'day_entry_provider.g.dart';

@riverpod
Stream<Map<DateTime, DayEntryModel>> monthEntries(Ref ref, DateTime start) {
  final end = DateTime(start.year, start.month + 1, 0);
  return const DayEntryStorage().monthEntries(start, end);
}

@riverpod
Stream<DayEntryModel?> dayEntry(Ref ref, DateTime date) {
  return const DayEntryStorage().dayEntryStream(date);
}
