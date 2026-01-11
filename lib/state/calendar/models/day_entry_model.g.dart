// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DayEntryModel _$DayEntryModelFromJson(
  Map<String, dynamic> json,
) => _DayEntryModel(
  date: json['date'] as String,
  icons: json['icons'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  medication:
      json['medication'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  notes: json['notes'] as String? ?? '',
  reminder: json['reminder'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DayEntryModelToJson(_DayEntryModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'icons': instance.icons,
      'medication': instance.medication,
      'notes': instance.notes,
      'reminder': instance.reminder,
    };
