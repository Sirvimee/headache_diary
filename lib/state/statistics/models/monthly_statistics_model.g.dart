// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyStatisticsModel _$MonthlyStatisticsModelFromJson(
  Map<String, dynamic> json,
) => _MonthlyStatisticsModel(
  title: json['title'] as String,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  headacheDays: json['headacheDays'] as String,
  rightSide: json['rightSide'] as String,
  leftSide: json['leftSide'] as String,
  overhead: json['overhead'] as String,
  pills: json['pills'] as String,
  systal: json['systal'] as String,
  run: json['run'] as String,
  strength: json['strength'] as String,
  sex: json['sex'] as String,
  alcohol: json['alcohol'] as String,
  menstruation: json['menstruation'] as String,
  chocolate: json['chocolate'] as String,
  doctor: json['doctor'] as String,
  eyePain: json['eyePain'] as String,
  vomit: json['vomit'] as String,
  preventivePill: json['preventivePill'] as String,
);

Map<String, dynamic> _$MonthlyStatisticsModelToJson(
  _MonthlyStatisticsModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'year': instance.year,
  'month': instance.month,
  'headacheDays': instance.headacheDays,
  'rightSide': instance.rightSide,
  'leftSide': instance.leftSide,
  'overhead': instance.overhead,
  'pills': instance.pills,
  'systal': instance.systal,
  'run': instance.run,
  'strength': instance.strength,
  'sex': instance.sex,
  'alcohol': instance.alcohol,
  'menstruation': instance.menstruation,
  'chocolate': instance.chocolate,
  'doctor': instance.doctor,
  'eyePain': instance.eyePain,
  'vomit': instance.vomit,
  'preventivePill': instance.preventivePill,
};
