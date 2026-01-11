import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class MonthlyStatisticsPayload extends MapView<String, String> {
  MonthlyStatisticsPayload({
    required String title,
    required int year,
    required int month,
    required String headacheDays,
    required String rightSide,
    required String leftSide,
    required String overhead,
    required String pills,
    required String systal,
    required String run,
    required String strength,
    required String sex,
    required String alcohol,
    required String menstruation,
  }) : super({
    'title': title,
    'year': year.toString(),
    'month': month.toString(),
    'headacheDays': headacheDays,
    'rightSide': rightSide,
    'leftSide': leftSide,
    'overhead': overhead,
    'pills': pills,
    'systal': systal,
    'run': run,
    'strength': strength,
    'sex': sex,
    'alcohol': alcohol,
    'menstruation': menstruation,
  });
}

