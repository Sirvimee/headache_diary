import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class DayEntryPayload extends MapView<String, dynamic> {
  DayEntryPayload({
    required String date,
    Map<String, dynamic>? icons,
    Map<String, dynamic>? medication,
    String? notes,
    Map<String, dynamic>? reminder,
  }) : super({
    'date': date,
    'icons': icons ?? {},
    'medication': medication ?? {},
    'notes': notes ?? '',
    'reminder': reminder,
  });
}

